 package Pod::JSchema::Block;
 
 use Moose;
 has tag => ( is => 'ro', required => 1 );
 has body => ( is => 'ro' );
 
 
 sub add_body{
    my $self = shift;
    my $text = shift;
    
    $self->{body} .= $text;
    
 }
 1;