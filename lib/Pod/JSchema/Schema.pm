package Pod::JSchema::Schema;

use Moose;
has schema => (is => 'ro');

my $tab = "  ";
my %display_types = ( array => 'array of' );
my %json_nested = ( map { $_ => 1 } qw'array object' );

sub markdown{
    my $self = shift;
    
    _markdown_recurse( $self->schema,'', -1);
}

sub _markdown_recurse{
    my $node = shift;
    my $name = shift;
    my $tier = shift;
    ref($node) eq 'HASH' || die "Must be hashref";

    my $out = '';
    my $line = '';
    if ($name){
        $line = ($tab x $tier) . "* **`$name`**";
        $line .= ' required' if $node->{required};
        $line .= " - " . ( $display_types{ $node->{type} } || $node->{type} );
        $line .= ($tab x $tier) . "  \n $node->{description}" if defined $node->{description};
    }
    
    if( $node->{type} eq 'object' ){
        foreach my $keyname ( keys %{ $node->{properties} } ){
            my $item = $node->{properties}{ $keyname };
            $out .= _markdown_recurse( $item, $keyname, $tier + 1 );
        }
    }elsif( $node->{type} eq 'array' ){
        my $child = $node->{items};
        
        if ( $child && $json_nested{ $child->{type} } ){
            $line .= ':';
            $out .= _markdown_recurse( $child, '', $tier);
        }elsif( $child->{type} ){
            $line .= ": $child->{type}s";
        }
    }else{
        #$out .= " ---- $node->{type}\n";
    }
    
    $line .= "\n" if $name;
    return $line . $out;
}