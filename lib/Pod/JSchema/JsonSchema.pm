package Pod::JSchema::JsonSchema;

use Moose;
use HTML::Entities;

has schema => (is => 'ro');

my $tab = "  ";
my %display_types = ( array => 'array of' );
my %json_nested = ( map { $_ => 1 } qw'array object' );

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
    if ($name){
        my $class = $display_types{ $node->{type} } || $node->{type};
        
        $line = $pad . qq'<li class="parameter"><span class="key $class">' . encode_entities($name) . '</span>';
        $line .= ' required' if $node->{required};
        $line .= " - $class";
        $line .=  qq'\n$pad$tab<div class="description">' . encode_entities($node->{description} ) . "</div>\n$pad" if defined $node->{description};
    }
    
    if( $node->{type} eq 'object' ){
        if ( %{ $node->{properties} || {} } ){
            $out .= qq'$pad<ul class="object">\n';
            foreach my $keyname ( keys %{ $node->{properties} } ){
                my $item = $node->{properties}{ $keyname };
                $out .= _html_recurse( $item, $keyname, $tier + 1 );
                
            }
            $out .= "$pad</ul> <!-- end object -->\n";
        }
    }elsif( $node->{type} eq 'array' ){
        my $child = $node->{items};
        if ( $child && $json_nested{ $child->{type} } ){
            $out .= qq'\n$pad<div class="array">\n';
            $line .= ':';
            $out .= _html_recurse( $child, '', $tier + 1 );
            $out .= "$pad</div> <!-- end array -->\n";
        }elsif( $child->{type} ){
            $line .= qq': <div class="array">$child->{type}s</div>\n';
        }
    }else{
        #$out .= " ---- $node->{type}\n";
    }
    
    $out .= "</li>\n" if length $line;
    return "$line$out";
}