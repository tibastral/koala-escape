class GameWindow < Hasu::Window
  WIDTH = 1024
  HEIGHT = 768
  SPRITE_SIZE = 128
  X_MAX = WIDTH - SPRITE_SIZE
  Y_MAX = HEIGHT - SPRITE_SIZE
  SPRITE_HALF_SIZE = SPRITE_SIZE / 2

  def initialize
    super(WIDTH, HEIGHT, false)

    @background = Gosu::Image.new(self, 'images/background.png', true)
    @koala = Gosu::Image.new(self, 'images/koala.png', true)
    @enemy_sprite = Gosu::Image.new(self, 'images/enemy.png', true)
    @flag = Gosu::Image.new(self, 'images/flag.png', true)
    @font = Gosu::Font.new(self, Gosu::default_font_name, 30)
    reset
  end

  def reinit
    @x = X_MAX
    @y = Y_MAX
    @level += 1
    @speed = @level + 2
    @finish_area_x = 0
    @finish_area_y = 0
    @enemies << {x: rand(40) + WIDTH / 2, y: rand(40) + HEIGHT / 2}
  end

  def reset
    @level = 0
    @enemies = []
    reinit
  end

  def update
    handle_direction
    handle_enemies
    handle_win
    handle_loose
    handle_quit
  end

  def handle_win
    if winning?
      @winning_timer = 50
      reinit
    end
  end

  def handle_loose
    if loosing?
      @loosing_timer = 50
      reset
    end
  end

  def draw
    (0..8).each do |x|
      (0..8).each do |y|
        @background.draw(x * 128, y * 128, 0)
      end
    end
    @enemies.map{|e| @enemy_sprite.draw(e[:x], e[:y], 2)}
    @koala.draw(@x, @y, 2)
    @flag.draw(@finish_area_x, @finish_area_y, 1)
    @font.draw("Level #{@level}", WIDTH - 100, 10, 1, 1.0, 1.0, Gosu::Color::BLACK)
    if !@winning_timer.nil? && @winning_timer > 0
      @winning_timer -= 1
      @font.draw("LEVEL #{@level} !!", WIDTH / 2 - 30, HEIGHT / 2, 1.0, 1.0, 1.0, Gosu::Color::GREEN)
    end
    if !@loosing_timer.nil? && @loosing_timer > 0
      @loosing_timer -= 1
      @font.draw('GAME OVER !!!', WIDTH / 2 - 30, HEIGHT / 2, 1.0, 1.0, 1.0, Gosu::Color::RED)
    end
  end

  private

  def handle_direction
    @x -= @speed if button_down? Gosu::Button::KbLeft
    @x += @speed if button_down? Gosu::Button::KbRight
    @y -= @speed if button_down? Gosu::Button::KbUp
    @y += @speed if button_down? Gosu::Button::KbDown
    @x = normalize(@x, X_MAX)
    @y = normalize(@y, Y_MAX)
  end

  def winning?
    (@x - @finish_area_x).abs < SPRITE_HALF_SIZE &&
    (@y - @finish_area_y).abs < SPRITE_HALF_SIZE
  end

  def loosing?
    @enemies.any? do |e|
      (@x - e[:x]).abs < SPRITE_HALF_SIZE &&
      (@y - e[:y]).abs < SPRITE_HALF_SIZE
    end
  end

  def random_dir
    rand(3) - 1
  end

  def normalize(v, max)
    if v < 0
      0
    elsif v > max
      max
    else
      v
    end
  end

  def handle_enemies
    @enemies = @enemies.map do |e|
      e[:timer] ||= 0
      if e[:timer] == 0
        e[:x_stay] = random_dir
        e[:y_stay] = random_dir
        e[:timer] = rand(75)
      end
      if e[:timer] > 0
        e[:timer] -= 1
      end
      e[:x] += e[:x_stay] * @speed
      e[:y] += e[:y_stay] * @speed
      e[:x] = normalize(e[:x], X_MAX)
      e[:y] = normalize(e[:y], Y_MAX)
      e
    end
  end

  def handle_quit
    if button_down? Gosu::KbEscape
      close
    end
  end
end
