class GameWindow < Hasu::Window
  WIDTH = 1024
  HEIGHT = 768
  SPEED = 3
  X_MAX = WIDTH - 128
  Y_MAX = HEIGHT - 128

  def initialize
    super(WIDTH, HEIGHT, false)

    @background = Gosu::Image.new(self, 'images/background.png', true)
    @koala = Gosu::Image.new(self, 'images/koala.png', true)
    @enemy_sprite = Gosu::Image.new(self, 'images/enemy.png', true)
    @flag = Gosu::Image.new(self, 'images/flag.png', true)
    @font = Gosu::Font.new(self, Gosu::default_font_name, 30)
    reinit
  end

  def reinit
    @x = X_MAX
    @y = Y_MAX
    @finish_area_x = 0
    @finish_area_y = 0
    @enemies ||= []
    @enemies << {x: rand(40), y: rand(40)}
  end

  def update
    unless @loosing
      handle_direction
      handle_win
      handle_loose
      handle_enemies
    end
    handle_quit
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
    @font.draw(@enemies.count, 10, 10, 1, 1.0, 1.0, Gosu::Color::BLACK)
    if @winning
      @font.draw('GAGNÉ !!!', 400, 300, 1.0, 1.0, 1.0, Gosu::Color::BLACK)
      reinit
    end
    if @loosing
      @font.draw('GAME OVER !!!', 400, 300, 1.0, 1.0, 1.0, Gosu::Color::RED)
    end
  end

  private

  def handle_direction
    @x -= SPEED if button_down? Gosu::Button::KbLeft
    @x += SPEED if button_down? Gosu::Button::KbRight
    @y -= SPEED if button_down? Gosu::Button::KbUp
    @y += SPEED if button_down? Gosu::Button::KbDown
    @x = normalize(@x, X_MAX)
    @y = normalize(@y, Y_MAX)
  end

  def handle_win
    @winning =  (@x - @finish_area_x).abs < 64 && (@y - @finish_area_y).abs < 64
  end

  def handle_loose
    @loosing ||= @enemies.any? do |e|
      (@x - e[:x]).abs < 64 &&
      (@y - e[:y]).abs < 64
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
      e[:for_how_long] ||= 0
      if e[:for_how_long] == 0
        e[:x_stay] = random_dir
        e[:y_stay] = random_dir
        e[:for_how_long] = rand(75)
      end
      if e[:for_how_long] > 0
        e[:for_how_long] -= 1
      end
      e[:x] += e[:x_stay] * SPEED
      e[:y] += e[:y_stay] * SPEED
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
