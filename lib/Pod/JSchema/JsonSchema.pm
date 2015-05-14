package Pod::JSchema::JsonSchema;

use Moose;
use HTML::Entities;

has schema => (is => 'ro');

my $tab = "  ";
my %display_types = ( array => 'array of' );
my %json_nested = ( map { $_ => 1 } qw'array object' );

# THIS IS A HACK
sub rawlocate{
    my ($self, $path) = @_;
    my @path = split('/',$path);
    
    my $ref = $self->schema;
    foreach my $part (@path){
        (ref($ref) eq 'HASH') && defined($ref->{$part}) or return undef;
        $ref = $ref->{$part};
    }
    return $ref;
}
sub markdown{
    my $self = shift;
    
    return _markdown_recurse( $self->schema,'', -1);
    
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

sub html{
    my $self = shift;
    return _html_recurse( $self->schema,'', -1);
}

sub _html_recurse{
    my $node = shift;
    my $name = shift;
    my $tier = shift;
    ref($node) eq 'HASH' || die "Must be hashref";
    
    my $out = '';
    my $line = '';
    my $tab = "    ";
    my $pad = ($tab x ($tier+1));

    my $class = $display_types{ $node->{type} } || $node->{type};
        
    $line = $pad . qq'<span class="key $node->{type}">' . encode_entities($name) . '</span>' if $name;
    $line .= ' required' if $node->{required};
    $line .= " - " if $name;
    $line .= " $class" if $class ne 'object';
    $line .=  qq'\n$pad$tab<div class="description">' . encode_entities($node->{description} ) . "</div>\n$pad" if defined $node->{description};
        
    if( $node->{type} eq 'object' ){
        if ( %{ $node->{properties} || {} } ){
            $out .= qq'$pad<ul class="object">\n';
            foreach my $keyname ( sort { lc($a) cmp lc($b) } keys %{ $node->{properties} } ){
                my $item = $node->{properties}{ $keyname };
                $out .= '<li class="parameter">' . _html_recurse( $item, $keyname, $tier + 1 ) . '</li>';
                
            }
            $out .= "$pad</ul> <!-- end object -->\n";
        }
    }elsif( $node->{type} eq 'array' ){
        my $child = $node->{items};
        if ( $child ){
            $out .= qq'\n$pad<div class="array">\n';
            $line .= ':';
            $out .= _html_recurse( $child, '', $tier + 1 );
            $out .= "$pad</div> <!-- end array -->\n";
        }
    }else{
        #$out .= " ---- $node->{type}\n";
    }
    
    return "$line$out";
}
