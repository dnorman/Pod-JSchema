package Pod::JSchema::Method;

use Moose;

has name   => ( is => 'ro' );
has tags   => ( is => 'ro', isa => 'HashRef', default => sub { {} } );
has blocks => ( is => 'ro', isa => 'ArrayRef[Pod::JSchema::Block]', trigger => \&_set_blocks );


sub _set_blocks{
    my $self = shift;
    
    my %TAGS;
    foreach my $block (@{ $self->blocks } ){
        $TAGS{ lc $block->tag }++;
    }
    
    $self->{tags} = \%TAGS;
    
}

sub markdown{
    my $self = shift;
    
    my $out = '';    
    foreach my $block (@{ $self->blocks } ){
        $out .= $block->markdown;
    }
    
    if ( !$self->tags->{head1} ){
        my $name = ucfirst( lc($self->name) );
        $out = "Method: $name\n" . ('-' x length($name) ) . "\n\n" . $out; 
    }
    
    return $out;
}

sub html{
    my $self = shift;
    
    my $name = ucfirst( lc($self->name) );
    my $out = qq'<a name="$name"><div class="method">\n';    
    foreach my $block (@{ $self->blocks } ){
        $out .= $block->html;
    }
    
    if ( !$self->tags->{head1} ){
        $out = '<div class="head1">Method: ' . "$name</div>\n" . $out; 
    }
    
    $out .= qq'</div></a>\n';
    return $out;
}
1;