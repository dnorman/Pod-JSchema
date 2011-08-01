package Pod::JSchema::Parser;

use strict;
use base 'Pod::Parser';

use Pod::JSchema::Method;
use Module::Pluggable require => 1, search_path => 'Pod::JSchema::Block', sub_name => 'blockmods';

my %BLOCKS;
BEGIN{
    foreach my $module ( __PACKAGE__->blockmods ){
        map { $BLOCKS{lc $_} ||= $module } $module->accept_tags;
    }
}

sub begin_pod {
    my $self = shift;
}

sub command { 
    my ($self, $command, $paragraph, $line_num, $pod_para) = @_;
    #print "COMMAND '$command'\n";
    
    my ($display, $tag);
    
    if ( $command eq 'for' || $command eq 'begin' ){
        $paragraph =~ s/^(\w{3,20})\s+//;
        $tag = uc($1);
        
        $display = "$command $tag";
    }else{
        $display = $command;
        $tag = $command;
    }
    
    my $block;
    
    if ( my $module = $BLOCKS{ lc $tag } ){
        eval{ $block = $module->_parse( lc($tag), $paragraph ) };
        if ($@){
            warn "parsing ==$command $tag block (line $line_num) failed. Error: $@";
        }
    }
    
    if ( $block ){
        $self->{_lastblock} = $block;
        push @{ $self->{_blocks}    ||=[] }, $block;
        push @{ $self->{_allblocks} ||=[] }, $block;
    }
    
}

sub preprocess_line{
    my ($self,$textline,$lineno) = @_;
    
    if ($textline =~ /\s*sub\s+(\w+)([^{]*){/ ){
        my ($method,$attr) = ($1,$2);
        
        $self->process_sub( $method, $attr );
        
    }
    return $textline;
}

sub process_sub{
    my $self = shift;
    my $method = shift;
    my $attr = shift;
    
    push @{$self->{_methods}}, Pod::JSchema::Method->new(
                                                name   => $method,
                                                blocks => ( delete $self->{_blocks} ) || []
                                            );
    
}

sub verbatim { 
    my ($parser, $paragraph, $line_num, $pod_para) = @_;
    #push @{ $self->{'-paragraphs'} }, $pod_para;
}

sub textblock { 
    my ($self, $paragraph, $line_num, $pod_para) = @_;
    
    if ( defined $self->{_lastblock} ){
        $self->{_lastblock}->add_body( $paragraph );
    }
    #my $ptree = $parser->parse_text({%options}, $paragraph );
    #$pod_para->parse_tree( $ptree );
    #push @{ $self->{'-paragraphs'} }, $pod_para;
}

1;