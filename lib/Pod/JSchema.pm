package Pod::JSchema;

use Pod::JSchema::Parser;
use Moose;

has parser => (is => 'ro', default => sub { Pod::JSchema::Parser->new } );
has filename => (is => 'ro', required => 1);
has methods  => (is => 'rw');
has blocks   => (is => 'rw');

sub BUILD{
    my $self = shift;
    $self->parser->parse_from_file( $self->filename );
    
    $self->methods( delete $self->parser->{_methods} || [] );
    $self->blocks( delete $self->parser->{_allblocks} || [] );
}

1;
