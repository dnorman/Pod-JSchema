package Pod::JSchema::Method;

use Moose;

has name => (is => 'ro');
has blocks => (is => 'ro', isa => 'ArrayRef[Pod::JSchema::Block]');

1;