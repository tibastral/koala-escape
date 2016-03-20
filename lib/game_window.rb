class GameWindow < Hasu::Window
  WIDTH = 1024
  HEIGHT = 768
  SPEED = 3

  def initialize
    super(WIDTH, HEIGHT, false)
    @background = Gosu::Image.new(self, 'images/background.png', true)
    @koala = Gosu::Image.new(self, 'images/koala.png', true)
    @enemy = Gosu::Image.new(self, 'images/enemy.png', true)
    @flag = Gosu::Image.new(self, 'images/flag.png', true)
    @font = Gosu::Font.new(self, Gosu::default_font_name, 30)
    reinit
  end

  def reinit
    @x = 800
    @y = 600
    @finish_area_x = 0
    @finish_area_y = 0
    @enemy_x = rand(40)
    @enemy_y = rand(40)
  end

  def update
    unless @loosing
      handle_direction
      handle_win
      handle_loose
      handle_enemy
    end
    handle_quit
  end

  def draw
    (0..8).each do |x|
      (0..8).each do |y|
        @background.draw(x * 128, y * 128, 0)
      end
    end
    @enemy.draw(@enemy_x, @enemy_y, 2)
    @koala.draw(@x, @y, 2)
    @flag.draw(@finish_area_x, @finish_area_y, 1)
    if @winning
      @font.draw('GAGNÉ !!!', 400, 300, 1.0, 1.0, 1.0, Gosu::Color::BLACK)
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
  end

  def handle_win
    @winning =  (@x - @finish_area_x).abs < 64 && (@y - @finish_area_y).abs < 64
  end

  def handle_loose
    @loosing = (@x - @enemy_x).abs < 64 && (@y - @enemy_y).abs < 64
  end

  def random_dir
    rand(3) - 1
  end

  def handle_enemy
    @for_how_long ||= 0
    if @for_how_long == 0
      @x_stay = random_dir
      @y_stay = random_dir
      @for_how_long = rand(75)
    end

    if @for_how_long > 0
      @for_how_long -= 1
    end

    puts @for_how_long

    @enemy_x += @x_stay * SPEED
    @enemy_y += @y_stay * SPEED
    if @enemy_x < 0
      @enemy_x = 0
    end
    if @enemy_y < 0
      @enemy_y = 0
    end

    if @enemy_x > 800
      @enemy_x = 800
    end
    if @enemy_y > 600
      @enemy_y = 600
    end
  end

  def handle_quit
    if button_down? Gosu::KbEscape
      close
    end
  end
end
