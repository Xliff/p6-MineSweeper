use v6.c;

use GTK::Button;
use GTK::CSSProvider;
use GTK::Grid;
use GTK::Window;

use MineSweeper::Logic;

unit class MineSweeper::Grid;

# Maybe wrap this to keep client code from abusing it, but maybe that's
# being too paranoid?
has $.game-finished

has $!win;
has $!grid;
has $!logic;
has @!buttons;

method new(MineSweeper::Logic $l) {
  $!game-finished = Promise.new;
  $!logic = $l;
  $!win  = GTK::Window.new('p6-GTK MineSweeper');
  $!grid = GTK::Grid.new;
  $!win.add($!grid);
  for ^$height X ^$width -> ($y, $x) {
    my $b = @!grid[$y][$x] = GTK::Button.new;
    $b.set_size_request(20, 20);
    $b.button-press-event.tap(-> *@a { self.do_click($x, $y, @a) });
    $!grid.attach($x, $y, 1, 1);
  }
}

method rescan {
  # Check logic grid to see what's been open and mark accordingly
}

method mark($x, $y) {
  $l.mark($y, $x);
  my $cl = $!grid.get_widget_at($x, $y);
  $cl.label = $cl.label eq '⚑' ?? '' !! '⚑';
}

method open($x, $y) {
  $l.open($y, $x);
  self.rescan;
}

method do_button_click($x, $y, @ed) {
  if @ed[1].type == GDK_BUTTON_PRESS {
    given @ed[1] {
      # Find correct enum
      when .button == 3 { self.mark($x, $y) }
      when .button == 1 { self.open($x, $y) }
    }
  }
}
