class GameWindow < Hasu::Window
  SPRITE_SIZE = 128
  WINDOW_X = 1024
  WINDOW_Y = 768

  def initialize
    super(WINDOW_X, WINDOW_Y, false)
    @background_sprite = Gosu::Image.new(self, 'images/background.png', true)
    @koala_sprite = Gosu::Image.new(self, 'images/koala.png', true)
    @enemy_sprite = Gosu::Image.new(self, 'images/enemy.png', true)
    @flag_sprite = Gosu::Image.new(self, 'images/flag.png', true)
    @font = Gosu::Font.new(self, Gosu::default_font_name, 30)
    @flag = {x: WINDOW_X - SPRITE_SIZE, y: WINDOW_Y - SPRITE_SIZE}
    @music = Gosu::Song.new(self, "musics/koala.wav")
    reset
  end

  def update
    @player[:x] += @speed if button_down?(Gosu::Button::KbRight)
    @player[:x] -= @speed if button_down?(Gosu::Button::KbLeft)
    @player[:y] += @speed if button_down?(Gosu::Button::KbDown)
    @player[:y] -= @speed if button_down?(Gosu::Button::KbUp)
    @player[:x] = normalize(@player[:x], WINDOW_X - SPRITE_SIZE)
    @player[:y] = normalize(@player[:y], WINDOW_Y - SPRITE_SIZE)
    handle_enemies
    handle_quit
    if winning?
      reinit
    end
    if loosing?
      reset
    end
  end

  def draw
    @font.draw("Level #{@enemies.length}", WINDOW_X - 100, 10, 3, 1.0, 1.0, Gosu::Color::BLACK)

    @koala_sprite.draw(@player[:x], @player[:y], 2)
    @enemies.each do |enemy|
      @enemy_sprite.draw(enemy[:x], enemy[:y], 2)
    end
    @flag_sprite.draw(@flag[:x], @flag[:y], 1)
    (0..8).each do |x|
      (0..8).each do |y|
        @background_sprite.draw(x * SPRITE_SIZE, y * SPRITE_SIZE, 0)
      end
    end
  end

  private

  def reset
    @high_score = 0
    @enemies = []
    @speed = 3
    if @music
      @music.stop
      @music.play
    end
    reinit
  end

  def reinit
    @speed += 1
    @player = {x: 0, y: 0}
    @enemies.push({x: 500 + rand(100), y: 200 + rand(300)})
    high_score
  end

  def high_score
    unless File.exist?('hiscore')
      File.new('hiscore', 'w')
    end
    @new_high_score = [@enemies.count, File.read('hiscore').to_i].max
    File.write('hiscore', @new_high_score)
  end

  def collision?(a, b)
    (a[:x] - b[:x]).abs < SPRITE_SIZE / 2 &&
    (a[:y] - b[:y]).abs < SPRITE_SIZE / 2
  end

  def loosing?
    @enemies.any? do |enemy|
      collision?(@player, enemy)
    end
  end

  def winning?
    collision?(@player, @flag)
  end

  def random_mouvement
    (rand(3) - 1)
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

  def handle_quit
    if button_down? Gosu::KbEscape
      close
    end
  end

  def handle_enemies
    @enemies = @enemies.map do |enemy|
      enemy[:timer] ||= 0
      if enemy[:timer] == 0
        enemy[:result_x] = random_mouvement
        enemy[:result_y] = random_mouvement
        enemy[:timer] = 50 + rand(50)
      end
      enemy[:timer] -= 1

      new_enemy = enemy.dup
      new_enemy[:x] += new_enemy[:result_x] * @speed
      new_enemy[:y] += new_enemy[:result_y] * @speed
      new_enemy[:x] = normalize(new_enemy[:x], WINDOW_X - SPRITE_SIZE)
      new_enemy[:y] = normalize(new_enemy[:y], WINDOW_Y - SPRITE_SIZE)
      unless collision?(new_enemy, @flag)
        enemy = new_enemy
      end
      enemy
    end
  end
end
