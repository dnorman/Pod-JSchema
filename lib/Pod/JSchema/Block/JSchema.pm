package Pod::JSchema::Block::JSchema;

use Moose;
use JSON::PP;
use Pod::JSchema::JsonSchema;
use Carp;

extends 'Pod::JSchema::Block';

has [qw'param_schema return_schema'] => (is => 'ro');
has method => ( is => 'ro' );

sub accept_tags { qw'JSCHEMA JSDT' }

sub _parse{
    my $pkg  = shift;
    my $tag  = shift;
    my $json = shift;
    my $common = shift || {};
    
    my $data = JSON::PP->new->allow_barekey->relaxed->decode( $json );
    
    if ( uc($tag) eq 'JSCHEMA'){
    
        my $params = $data->{parameters} || $data->{params} || $data->{in};
        my $return = $data->{returns}    || $data->{return} || $data->{out};
        
        my %out = ( type => 'jschema' );
        if ( $data->{method} ){
            $out{method} = $data->{method};
        }
        
        if ($params){
            $out{param_schema} = Pod::JSchema::JsonSchema->new ( schema => _shorthand_to_jschema_recurse($params, $common) );
        }
        if ($return){
            $out{return_schema} = Pod::JSchema::JsonSchema->new ( schema => _shorthand_to_jschema_recurse($return, $common) );
        }
        
        return __PACKAGE__->new ( %out, tag => $tag );
    }elsif(uc($tag) eq 'JSDT'){
        
        croak "Invalid JSDT tag. Must contain at least one datatype definition" unless ref($data) eq 'HASH' && %$data;
        foreach my $type ( keys %$data ){
            $common->{Modules}{JSchema}{JSDT}{$type} = _shorthand_to_jschema_recurse( $data->{$type}, $common );
        }
        return undef;
    }
    
}


my %json_types = ( map{ $_ => 1 } qw'string number integer boolean object array null any' );

sub _shorthand_to_jschema_recurse{
    my $in = shift;
    my $common = shift;
    
    my $ref = ref($in);
    my $out = {};
    if( !$ref && length($in) ){
        
        my @parts = split(/\s*[:\+]\s*/, $in);
        my ($type) = grep { $json_types{lc($_)} } @parts;
        my ($req)  = grep { $_ =~ /^(r|req|required)$/i } @parts;
        my ($dt)   = grep { $_ =~ /^dt=.+$/i } @parts;
        my %remove = map {$_ => 1} grep {defined} ($type, $req, $dt);
        
        @parts = grep { !$remove{$_} } @parts;
        my ($desc) = $parts[0] if scalar(@parts) && length( $parts[0] ) > 9;
        
        $out->{type} = defined $type ? lc($type) : 'string';
        $out->{required} = JSON::PP::true if ( defined $req );
        $out->{description} = $desc if defined $desc;
        
        if ($dt){
            my ($type) = $dt =~ /=(.*)$/;
            if (length $type){
                my $ref = $common->{Modules}{JSchema}{JSDT}{$type} or croak "DataType '$type' not found";
                %$out = (%$out, %$ref);
            }
        }
        
    }elsif ( $ref eq 'HASH'){
        $out = {
                type => 'object',
                properties => {},
            };
        
        map { $out->{properties}{$_} = _shorthand_to_jschema_recurse( $in->{$_}, $common ) } keys %$in;
        
    }elsif( $ref eq 'ARRAY' ){
        die "incorrect number of elements in array, expect just one" if @$in != 1;
        $out = {
            type => 'array',
            items => _shorthand_to_jschema_recurse( $in->[0], $common ),
        };
    }
    
    return $out;
}


sub markdown{
    my $self = shift;
    
    my $out = '';
    $out .= "### Schema\n\n";
    
    if ( $self->param_schema ){
        $out .= "Parameters:  \n\n";
        $out .= $self->param_schema->markdown;
        $out .= "\n";
    }
    
    if ( $self->return_schema ){
        $out .= "Returns:  \n\n";
        $out .= $self->return_schema->markdown;
        $out .=  "\n";
    }
    
    return $out;
}

sub html{
    my $self = shift;
    
    my $out = '';
    $out .= qq!<div class="block jschema block-jschema">\n!;
    $out .= qq!<div class="heading">Schema</div>\n!;

    $out .= qq!<div class="section">\n!;
    
    if ( $self->param_schema ){
        $out .= '<div class="schema param-schema">' . "\n";
        $out .= qq'<span class="heading">Parameters:</span>\n';
        $out .= $self->param_schema->html;
        $out .= "</div>\n";
    }
    
    if ( $self->return_schema ){
        $out .= '<div class="schema return-schema">' . "\n";
        $out .= qq'<span class="heading">Returns:</span>\n';
        $out .= $self->return_schema->html;
        $out .= "</div>\n";
    }
    
    $out .= "</div>\n";
    $out .= "</div><!-- end block -->\n";
    
    return $out;
}


1;