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
    $out .= qq!<div class="block $tag block-$tag">\n!;
    $out .= qq!<div class="heading">! . encode_entities( $self->title ) . "</div>\n";
    my $body = encode_entities($self->body);
    $body =~ s/  \n/<br\/>/g; #cheat it with markdown style linebreaks
    
    $out .= qq'<div class="section">$body</div>\n';
    $out .= "</div> <!-- end block -->\n";
    return $out;
}

1;