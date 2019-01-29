use v6.c;

unit package MineSweeper::Logic;

enum Tile-Type <Empty Mine>;

class X::MineSweeper           is Exception      is export { }
class X::MineSweeper::GameWon  is X::MineSweeper is export { }
class X::MineSweeper::GameLost is X::MineSweeper is export { }

class Tile {
  has Tile-Type $.type;
  has $.face is rw;
  method Str { with $!face { ~$!face } else { '.' } }
}

class Field {
    has @.grid;
    has Int $.width;
    has Int $.height;
    has Int $.mine-spots;
    has Int $.empty-spots;

    method new (Int $height, Int $width, Rat $mines-ratio=0.1) {
      my $mine-spots = round $width * $height * $mines-ratio;
      my $empty-spots = $width * $height - $mine-spots;

      my @grid;
      for ^$height X ^$width -> ($y, $x) {
        @grid[$y][$x] = Tile.new(type => Empty);
      }
      for
        (^$height).pick($mine-spots) Z (^$width).pick($mine-spots)
      -> ($y, $x) {
          @grid[$y][$x] = Tile.new( type => Mine);
      }
      self.bless(:$height, :$width, :@grid, :$mine-spots, :$empty-spots);
    }

    method open($y, $x) {
      return if @!grid[$y][$x].face.defined;

      self.end-game(:lost) if @!grid[$y][$x].type ~~ Mine;

      my @neighbors = gather do
        take [ $y + .[0], $x + .[1] ]
	        if 0 <= $y + .[0] < $!height && 0 <= $x + .[1] < $!width
	          for [-1,-1],[+0,-1],[+1,-1],
	              [-1,+0],        [+1,+0],
	              [-1,+1],[+0,+1],[+1,+1];

      my $mines = +@neighbors.grep: { @!grid[ .[0] ][ .[1] ].type ~~ Mine };

      $!empty-spots--;
      @!grid[$y][$x].face = $mines || ' ';

      if $mines == 0 {
        self.open(.[0], .[1]) for @neighbors;
      }
      self.end-game(:won) if $!empty-spots == 0;
    }

    method end-game(:$won = False, $lost =  False) {
      die '$won and $false cannot be the same value'
        unless $won ^^ $false;

      for ^$!height X ^$!width -> ($y, $x) {
        @!grid[$y][$x].face = '*' if @!grid[$y][$x].type ~~ Mine
      }
      if $won {
        X::MineSweeper::GameWon.new.throw;
      } else {
        X::MineSweeper::GameLost.new.throw;
      }
    }

    method mark ($y, $x) {
      if !@!grid[$y][$x].face.defined {
        @!grid[$y][$x].face = "⚐";
        $!mine-spots-- if @!grid[$y][$x].type ~~ Mine;
      } elsif !@!grid[$y][$x].face eq "⚐" {
        undefine @!grid[$y][$x].face;
        $!mine-spots++ if @!grid[$y][$x].type ~~ Mine;
      }
      self.end-game("You won") if $!mine-spots == 0;
    }

    constant @digs = |('a'..'z') xx *;

  method Str {
    [~] flat '  ', @digs[^$!width], "\n",
             ' ┌', '─' xx $!width, "┐\n",
        join '', do for ^$!height -> $y {
          $y, '│', @!grid[$y][*],  "│\n";
        },
             ' └', '─' xx $!width, '┘';
	}

  method valid ($y, $x) {
      0 <= $y < $!height && 0 <= $x < $!width
  }
}
