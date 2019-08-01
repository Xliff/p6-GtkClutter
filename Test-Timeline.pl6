use v6.c;

use JsonC;

use Clutter::Raw::Types;

use Clutter::Actor;
use Clutter::AlignConstraint;
use Clutter::BindConstraint;
use Clutter::BoxLayout;
use Clutter::ScrollActor;
use Clutter::Stage;

use Clutter::Main;

my $Timeline-Data;

my (%tasks, %events, %globals);

constant PIXEL-SECONDS = 100;

sub MAIN {
  exit(1) unless Clutter::Main.init == CLUTTER_INIT_SUCCESS;

  my $S = Supplier.new;
  my $supply = $S.Supply;
  %globals<init> = Promise.new;

  $supply.tap(-> *@a [$i, $t] {
    await %globals<init> if %globals<init>.status ~~ Planned;

    say "Adding task #{ $i }";
    %tasks{$i} = $t;

    my $tot = %tasks{$i}.values.map( *<dur> ).sum;
    # for %tasks.values {
    #   my $c = Clutter::BindConstraint.new( .<actor>.get-constraint('left') );
    #   $c.factor =
    # }

    my $c = Clutter::Color.new_from_hls(360 * rand, 0.5, 0.5);
    $c.alpha = 255;

    %globals<actors>.push: (
      %tasks{$i}<actor> = Clutter::Actor.new.setup(
        background-color    => $c,
        parent              => %globals<scroll>,
        constraints-by-name => [
          'left', Clutter::BindConstraint.new(CLUTTER_ALIGN_X_AXIS).setup(
            factor => *.dur / $sum
          )
        ]
      )
    );
  });

  start {
    my %t;
    for $Timeline-Data.lines {
      my $o = from-json($_);

      given $o<k> {
        when 0 | 1 {
          my %v := $_ ?? %t !! %events;
          quietly {
            %v{ $o<i> }<module category name start> = $o<m c n t d>
          }
          proceed;
        }

        when 1 {
          %t{ $o<p> }<child-tasks>.push: %t{ $o<i> } if $o<p>;
        }

        when 2 {
          %t{ $o<i> }<stop> = $o<t>;
          %t{ $o<i> }<dur>  = %t{ $o<i> }<stop> - %t{ $o<i> }<start>;
          $S.emit( [$o<i>, %t{ $o<i> }] ) if $o<p>.not;
        }
      }
    }
    say 'Done';
  }

  my $stage = Clutter::Stage.new.setup(
    name           => 'Log::Timeline Viewer',
    user-resizable => True,
  );

  my %globals<scroll> = Clutter::ScrollActor.new.setup(
    scroll-mode => CLUTTER_SCROLL_BOTH,
    # Change to a GridLayout
    layout      => Clutter::BoxLayout.new.setup(
        orientation => CLUTTER_ORIENTATION_VERTICAL
    ),
    constraints => [
      Clutter::AlignConstraint.new($stage, CLUTTER_ALIGN_X_AXIS, 0.5),
      Clutter::AlignConstraint.new($stage, CLUTTER_ALIGN_Y_AXIS, 0.5),
    ],
  );

  $stage.add-child(%globlas<scroll>);
  $stage.destroy.tap({ Clutter::Main.quit });
  $stage.activate.tap({
    %globals<init>.keep unless %globals<init>.status ~~ Kept
  });
  $stage.show-actor;

  Clutter::Main.run;
}

INIT $Timeline-Data = q:to/DATA/;
  {"t":1563976359.124227,"n":"Parse Tables of Content","k":1,"c":"Parser","d":{},"p":0,"i":1,"m":"HeapAnalyzer"}
  {"t":1563976359.131731,"n":"TOC found","d":{},"c":"Parser","k":0,"p":1,"m":"HeapAnalyzer"}
  {"n":"TOC found","t":1563976359.156362,"k":0,"c":"Parser","d":{},"p":1,"m":"HeapAnalyzer"}
  {"t":1563976359.185809,"n":"TOC found","k":0,"d":{},"c":"Parser","p":1,"m":"HeapAnalyzer"}
  {"p":1,"m":"HeapAnalyzer","n":"TOC found","t":1563976359.206919,"k":0,"c":"Parser","d":{}}
  {"k":0,"d":{},"c":"Parser","n":"TOC found","t":1563976359.223361,"m":"HeapAnalyzer","p":1}
  {"p":1,"m":"HeapAnalyzer","n":"TOC found","t":1563976359.235026,"k":0,"d":{},"c":"Parser"}
  {"n":"Parse Tables of Content","t":1563976359.257559,"c":"Parser","k":2,"i":1,"m":"HeapAnalyzer"}
  {"k":1,"c":"Parser","d":{},"t":1563976359.265987,"n":"Parse Strings","m":"HeapAnalyzer","p":0,"i":2}
  {"c":"Parser","d":{},"k":1,"t":1563976359.29878,"n":"Parse Static Frames","m":"HeapAnalyzer","p":0,"i":3}
  {"d":{},"c":"Parser","k":1,"t":1563976359.308194,"n":"Parse Static Types","m":"HeapAnalyzer","i":4,"p":0}
  {"m":"HeapAnalyzer","i":5,"p":3,"k":1,"c":"Parser","d":{"kind":"sffile","position":"27060d"},"t":1563976359.310415,"n":"Parse Attribute Stream"}
  {"d":{"kind":"sfcuid","position":"26f0fc"},"c":"Parser","k":1,"t":1563976359.317938,"n":"Parse Attribute Stream","m":"HeapAnalyzer","p":3,"i":6}
  {"i":7,"p":3,"m":"HeapAnalyzer","n":"Parse Attribute Stream","t":1563976359.357705,"k":1,"c":"Parser","d":{"kind":"sfline","position":"26fc23"}}
  {"t":1563976359.727646,"n":"Parse Attribute Stream","k":1,"d":{"kind":"sfname","position":"26edcd"},"c":"Parser","p":3,"i":8,"m":"HeapAnalyzer"}
  {"p":4,"i":9,"m":"HeapAnalyzer","t":1563976359.787908,"n":"Parse Attribute Stream","k":1,"d":{"kind":"typename","position":"26e35f"},"c":"Parser"}
  {"i":5,"m":"HeapAnalyzer","n":"Parse Attribute Stream","t":1563976359.812984,"c":"Parser","k":2}
  {"k":1,"d":{"position":"73d0dc","kind":"sffile"},"c":"Parser","t":1563976359.81378,"n":"Parse Attribute Stream","m":"HeapAnalyzer","p":3,"i":10}
  {"c":"Parser","d":{"position":"26e149","kind":"reprname"},"k":1,"n":"Parse Attribute Stream","t":1563976359.847522,"m":"HeapAnalyzer","i":11,"p":4}
  {"m":"HeapAnalyzer","i":6,"k":2,"c":"Parser","t":1563976359.979738,"n":"Parse Attribute Stream"}
  {"t":1563976359.980462,"n":"Parse Attribute Stream","k":1,"c":"Parser","d":{"position":"73d056","kind":"sfcuid"},"i":12,"p":3,"m":"HeapAnalyzer"}
  {"i":7,"m":"HeapAnalyzer","n":"Parse Attribute Stream","t":1563976360.014308,"k":2,"c":"Parser"}
  {"m":"HeapAnalyzer","i":13,"p":3,"d":{"kind":"sfline","position":"73d099"},"c":"Parser","k":1,"t":1563976360.014991,"n":"Parse Attribute Stream"}
  {"m":"HeapAnalyzer","i":11,"c":"Parser","k":2,"n":"Parse Attribute Stream","t":1563976360.6677}
  {"d":{"position":"73cfcb","kind":"reprname"},"c":"Parser","k":1,"t":1563976360.668395,"n":"Parse Attribute Stream","m":"HeapAnalyzer","i":14,"p":4}
  {"m":"HeapAnalyzer","i":10,"c":"Parser","k":2,"t":1563976360.717932,"n":"Parse Attribute Stream"}
  {"c":"Parser","k":2,"t":1563976360.722493,"n":"Parse Attribute Stream","m":"HeapAnalyzer","i":8}
  {"k":1,"d":{"position":"73d019","kind":"sfname"},"c":"Parser","n":"Parse Attribute Stream","t":1563976360.723173,"m":"HeapAnalyzer","p":3,"i":16}
  {"p":3,"i":15,"m":"HeapAnalyzer","t":1563976360.718601,"n":"Parse Attribute Stream","k":1,"c":"Parser","d":{"kind":"sffile","position":"9ac19a"}}
  {"m":"HeapAnalyzer","i":9,"k":2,"c":"Parser","n":"Parse Attribute Stream","t":1563976360.757021}
  {"t":1563976360.75766,"n":"Parse Attribute Stream","k":1,"d":{"position":"73cff2","kind":"typename"},"c":"Parser","p":4,"i":17,"m":"HeapAnalyzer"}
  {"i":13,"m":"HeapAnalyzer","n":"Parse Attribute Stream","t":1563976360.856784,"k":2,"c":"Parser"}
  {"p":3,"i":18,"m":"HeapAnalyzer","n":"Parse Attribute Stream","t":1563976360.884692,"k":1,"d":{"kind":"sfline","position":"9ac16f"},"c":"Parser"}
  {"i":12,"m":"HeapAnalyzer","t":1563976360.946299,"n":"Parse Attribute Stream","k":2,"c":"Parser"}
  {"k":1,"d":{"kind":"sfcuid","position":"9ac144"},"c":"Parser","t":1563976360.946964,"n":"Parse Attribute Stream","m":"HeapAnalyzer","p":3,"i":19}
  {"m":"HeapAnalyzer","i":14,"k":2,"c":"Parser","t":1563976361.431763,"n":"Parse Attribute Stream"}
  {"m":"HeapAnalyzer","p":4,"i":20,"c":"Parser","d":{"position":"9ac0db","kind":"reprname"},"k":1,"n":"Parse Attribute Stream","t":1563976361.432644}
  {"c":"Parser","k":2,"n":"Parse Attribute Stream","t":1563976361.528859,"m":"HeapAnalyzer","i":15}
  {"i":21,"p":3,"m":"HeapAnalyzer","n":"Parse Attribute Stream","t":1563976361.545932,"k":1,"d":{"position":"e743d2","kind":"sffile"},"c":"Parser"}
  {"n":"Parse Attribute Stream","t":1563976361.563438,"c":"Parser","k":2,"i":21,"m":"HeapAnalyzer"}
  {"m":"HeapAnalyzer","i":16,"k":2,"c":"Parser","n":"Parse Attribute Stream","t":1563976361.597919}
  {"m":"HeapAnalyzer","p":3,"i":22,"k":1,"d":{"position":"9ac119","kind":"sfname"},"c":"Parser","t":1563976361.598606,"n":"Parse Attribute Stream"}
  {"c":"Parser","k":2,"t":1563976361.647007,"n":"Parse Attribute Stream","m":"HeapAnalyzer","i":17}
  {"i":23,"p":4,"m":"HeapAnalyzer","n":"Parse Attribute Stream","t":1563976361.647792,"k":1,"d":{"position":"9ac0fa","kind":"typename"},"c":"Parser"}
  {"c":"Parser","k":2,"n":"Parse Attribute Stream","t":1563976361.834416,"m":"HeapAnalyzer","i":18}
  {"m":"HeapAnalyzer","i":19,"c":"Parser","k":2,"t":1563976361.834725,"n":"Parse Attribute Stream"}
  {"c":"Parser","d":{"kind":"sfcuid","position":"e7434c"},"k":1,"t":1563976361.835233,"n":"Parse Attribute Stream","m":"HeapAnalyzer","p":3,"i":25}
  {"i":25,"m":"HeapAnalyzer","t":1563976361.838839,"n":"Parse Attribute Stream","c":"Parser","k":2}
  {"k":1,"c":"Parser","d":{"position":"e7438f","kind":"sfline"},"t":1563976361.8352,"n":"Parse Attribute Stream","m":"HeapAnalyzer","i":24,"p":3}
  {"m":"HeapAnalyzer","i":2,"c":"Parser","k":2,"t":1563976361.846899,"n":"Parse Strings"}
  {"i":24,"m":"HeapAnalyzer","t":1563976361.860199,"n":"Parse Attribute Stream","c":"Parser","k":2}
  {"m":"HeapAnalyzer","i":20,"c":"Parser","k":2,"t":1563976362.071962,"n":"Parse Attribute Stream"}
  {"i":23,"m":"HeapAnalyzer","n":"Parse Attribute Stream","t":1563976362.145793,"c":"Parser","k":2}
  {"m":"HeapAnalyzer","i":4,"k":2,"c":"Parser","n":"Parse Static Types","t":1563976362.146532}
  {"i":22,"m":"HeapAnalyzer","n":"Parse Attribute Stream","t":1563976362.158228,"c":"Parser","k":2}
  {"d":{"kind":"sfname","position":"e74321"},"c":"Parser","k":1,"t":1563976362.158947,"n":"Parse Attribute Stream","m":"HeapAnalyzer","p":3,"i":26}
  {"i":26,"m":"HeapAnalyzer","t":1563976362.162371,"n":"Parse Attribute Stream","k":2,"c":"Parser"}
  {"c":"Parser","k":2,"n":"Parse Static Frames","t":1563976362.166276,"m":"HeapAnalyzer","i":3}
  {"k":1,"d":{"position":"5c8a5e","kind":"reftrget"},"c":"Parser","t":1563976362.682796,"n":"Parse Attribute Stream","m":"HeapAnalyzer","p":0,"i":27}
  {"n":"Parse Attribute Stream","t":1563976362.682796,"c":"Parser","d":{"kind":"refdescr","position":"593648"},"k":1,"p":0,"i":28,"m":"HeapAnalyzer"}
  {"m":"HeapAnalyzer","p":0,"i":30,"k":1,"d":{"kind":"colrfstr","position":"4ffb07"},"c":"Parser","n":"Parse Attribute Stream","t":1563976363.692719}
  {"m":"HeapAnalyzer","i":31,"p":0,"k":1,"c":"Parser","d":{"kind":"coltofi","position":"4dfdb2"},"n":"Parse Attribute Stream","t":1563976363.694102}
  {"m":"HeapAnalyzer","p":0,"i":29,"k":1,"d":{"position":"57eba5","kind":"colusize"},"c":"Parser","t":1563976363.694564,"n":"Parse Attribute Stream"}
  {"c":"Parser","d":{"position":"4d864f","kind":"colsize"},"k":1,"n":"Parse Attribute Stream","t":1563976363.694234,"m":"HeapAnalyzer","i":32,"p":0}
  {"i":33,"p":0,"m":"HeapAnalyzer","n":"Parse Attribute Stream","t":1563976363.694943,"c":"Parser","d":{"position":"4eed01","kind":"colrfcnt"},"k":1}
  {"m":"HeapAnalyzer","p":0,"i":34,"d":{"kind":"colkind","position":"4d676b"},"c":"Parser","k":1,"n":"Parse Attribute Stream","t":1563976364.158249}
  {"k":2,"c":"Parser","n":"Parse Attribute Stream","t":1563976367.672103,"m":"HeapAnalyzer","i":32}
  {"i":33,"m":"HeapAnalyzer","n":"Parse Attribute Stream","t":1563976368.158245,"c":"Parser","k":2}
  {"i":31,"m":"HeapAnalyzer","t":1563976368.26028,"n":"Parse Attribute Stream","c":"Parser","k":2}
  {"n":"Parse Attribute Stream","t":1563976368.629087,"c":"Parser","k":2,"i":34,"m":"HeapAnalyzer"}
  {"t":1563976370.969138,"n":"Parse Attribute Stream","k":2,"c":"Parser","i":30,"m":"HeapAnalyzer"}
  {"n":"Parse Attribute Stream","t":1563976371.17022,"c":"Parser","k":2,"i":29,"m":"HeapAnalyzer"}
  {"m":"HeapAnalyzer","i":27,"c":"Parser","k":2,"t":1563976376.580429,"n":"Parse Attribute Stream"}
  {"t":1563976376.76912,"n":"Parse Attribute Stream","k":2,"c":"Parser","i":28,"m":"HeapAnalyzer"}
  {"k":1,"c":"Parser","d":{"position":"3622e2","kind":"reftrget"},"n":"Parse Attribute Stream","t":1563976403.247723,"m":"HeapAnalyzer","p":0,"i":35}
  {"t":1563976403.252311,"n":"Parse Attribute Stream","k":1,"d":{"kind":"refdescr","position":"32d62d"},"c":"Parser","p":0,"i":36,"m":"HeapAnalyzer"}
  {"m":"HeapAnalyzer","p":0,"i":37,"d":{"position":"299c8d","kind":"colrfstr"},"c":"Parser","k":1,"n":"Parse Attribute Stream","t":1563976404.256167}
  {"c":"Parser","d":{"kind":"colrfcnt","position":"2891a5"},"k":1,"n":"Parse Attribute Stream","t":1563976404.272997,"m":"HeapAnalyzer","p":0,"i":38}
  {"m":"HeapAnalyzer","i":39,"p":0,"k":1,"c":"Parser","d":{"kind":"colusize","position":"318f30"},"n":"Parse Attribute Stream","t":1563976404.293792}
  {"c":"Parser","d":{"position":"270e5e","kind":"colkind"},"k":1,"n":"Parse Attribute Stream","t":1563976404.295239,"m":"HeapAnalyzer","i":40,"p":0}
  {"p":0,"i":41,"m":"HeapAnalyzer","t":1563976404.308461,"n":"Parse Attribute Stream","d":{"kind":"coltofi","position":"27a34b"},"c":"Parser","k":1}
  {"p":0,"i":42,"m":"HeapAnalyzer","t":1563976404.323454,"n":"Parse Attribute Stream","c":"Parser","d":{"kind":"colsize","position":"272ca0"},"k":1}
  {"n":"Parse Attribute Stream","t":1563976408.13076,"c":"Parser","k":2,"i":42,"m":"HeapAnalyzer"}
  {"c":"Parser","k":2,"n":"Parse Attribute Stream","t":1563976408.323065,"m":"HeapAnalyzer","i":40}
  {"c":"Parser","k":2,"n":"Parse Attribute Stream","t":1563976408.525618,"m":"HeapAnalyzer","i":41}
  {"i":38,"m":"HeapAnalyzer","n":"Parse Attribute Stream","t":1563976408.545069,"c":"Parser","k":2}
  {"i":37,"m":"HeapAnalyzer","t":1563976411.320042,"n":"Parse Attribute Stream","k":2,"c":"Parser"}
  {"c":"Parser","k":2,"t":1563976411.447823,"n":"Parse Attribute Stream","m":"HeapAnalyzer","i":39}
  {"i":36,"m":"HeapAnalyzer","n":"Parse Attribute Stream","t":1563976417.039024,"c":"Parser","k":2}
  {"n":"Parse Attribute Stream","t":1563976417.236629,"k":2,"c":"Parser","i":35,"m":"HeapAnalyzer"}
  DATA