package Data::Lotter;

use base qw( Class::Accessor::Fast );
use strict;
use 5.8.1;
our $VERSION = '0.00001_00';
use Data::Dumper;
use constant DEBUG => $ENV{DATA_LOTTER_DEBUG};

__PACKAGE__->mk_accessors qw( lists available );

sub new {
    my $class = shift;
    my %lists = @_;

    my $cumulative = 0;
    foreach my $weight ( values %lists ) {
        $weight = int($weight);
        $cumulative += $weight;
    }

    return $class->SUPER::new( { available => $cumulative, lists => \%lists } );
}

sub pickup {
    my $self   = shift;
    my $num    = shift;
    my $remove = shift || '';
    my @ret;

    my $lists = $self->lists;
  OUTER:
    while ( $num-- ) {
        Dumper $lists; # 本当はいらないけど、これがないとtestでこける?
        my $n = int( rand( $self->available ) ) + 1;
        if (DEBUG) {
            print "NUM:$num\n";
            print "-" x 10, "\n", "Random number: $n\n";
            print Dumper $lists;
        }
        while ( my ( $item, $weight ) = each %$lists ) {
            print "\tn = $n\n" if DEBUG;
            if ( $weight > 0 && $weight >= $n ) {
                push @ret, $item;
                print "\tHIT!\t$item was pushed\n" if DEBUG;
                if ($remove) {
                    delete $lists->{$item};
                    $self->available( $self->available - $weight );
                }
                else {
                    $lists->{$item} = $weight - 1;
                    $self->available( $self->available - 1 );
                }
                next OUTER;
            }
            $n -= $weight;
        }
    }
    print join( "\,", @ret ), "\n" if DEBUG;
    return @ret;
}

sub left_items {
    my $self  = shift;
    my @items = keys %{ $self->lists };
    return @items;
}

sub left_item_waits {
    my $self = shift;
    my $item = shift;
    return $self->lists->{$item};
}

1;

__END__

=head1 NAME

Data::Lotter - Data pickup module by its own weight

=head1 SYNOPSIS

  use Data::Lotter;

  # 抽選候補データを用意
  #  item => weight のhash
  my %candidates = (
    red    => 10,
    green  => 10,
    blue   => 10,
    yellow => 10,
    white  => 10, 
  );

  # データをセット
  my $lotter = Data::Lotter->new(%candidates);

  # 普通のpickup
  # 3つのアイテムを抽選(47個のアイテムwaitが残る)
  my @ret = $lotter->pickup(3);
  # ex. ( red, green, yellow ) = @ret

  # REMOVEオプションつきのpickup
  # 1つのアイテムを抽選（4つのアイテムが残る）
  my @ret = $lotter->pickup(1, "REMOVE");

=head1 DESCRIPTION

Data::Lotter is
データ抽選モジュールです。
itemとweightの値を持ったhashを「抽選候補データ」として準備します。
(weightは適当にばらけた数値を指定して構いません)

        red       green      blue       yellow      white
     ---------- ---------- ---------- ---------- ----------
     0123456789 0123456789 0123456789 0123456789 0123456789

ここから1つのデータを抽選するとします。
たとえば「35」が抽選の結果だったとします。

        red       green      blue       yellow      white
     ---------- ---------- ---------- ---------- ----------
     0123456789 0123456789 0123456789 0123456789 0123456789
                                          ^
                                          ↑ここ

抽選用のpickupメソッドが呼び出された後、データは以下のように抽選されたitemのweightが1つ減らされた状態になります。

        red       green      blue       yellow     white
     ---------- ---------- ---------- --------- ----------
     0123456789 0123456789 0123456789 012356789 0123456789
                                          ^
                                          ↑ここが消えた

REMOVEオプションをつけてpickupメソッドを呼び出すと、その番号を保有するitemごと削除されます。

        red       green      blue        white
     ---------- ---------- ---------- ----------
     0123456789 0123456789 0123456789 0123456789

                                         yellowごと消えた！



これにより複数の候補から複数のアイテムを繰り返し抽選する際に、
  * 福引のように「たくさんのくじの中から選ぶ」パターンと
  * 選挙のように「特定の誰かを何人か決める」ようなパターンの両方を実現できます。



=head1 METHODS

=head2 new()

=head2 pickup()

=head2 left_items()

=head2 left_item_waits()

=head1 AUTHOR

Takeshi Miki E<lt>miki@cpan.orgE<gt>

Original idea was spawned by KANEGON

Special thanks to Daisuke Maki

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut