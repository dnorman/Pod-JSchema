package Pod::JSchema::Block::Heading;

use Moose;
use HTML::Entities;

extends 'Pod::JSchema::Block';

has title => ( is => 'ro' );
has level => ( is => 'ro', default => 1 );

sub accept_tags { qw'head1 head2 head3 head4' }

sub _parse{
    my $pkg  = shift;
    my $tag  = shift;
    my $text = shift;
    
    
    my ($level) = $tag =~ /(\d+)/;
    my ($title) = $text =~ /^(.*?)[\n\r]/;
    return __PACKAGE__->new ( title => $title, tag => $tag, level => $level );
}

sub markdown{
    my $self = shift;
    
    my $out;
    $out .= "#" . ("#" x $self->level ) . ' ' .  $self->title . "\n";
    
    $out .= $self->body;
    
    return $out;
}

sub html{
    my $self = shift;
    
    my $out;
    my $tag = $self->tag;
    $out .= qq!<div class="heading $tag">! . encode_entities( $self->title ) . "</div>\n";

    $out .= encode_entities($self->body);
    
    return $out;
}

1;