package Pod::JSchema::Parser;

use strict;
use base 'Pod::Parser';

use Pod::JSchema::Method;
use Module::Pluggable require => 1, search_path => 'Pod::JSchema::Block', sub_name => 'blockmods';
use Pod::JSchema::Block::JSCHEMA;

my %BLOCKS;
BEGIN{
    foreach my $module ( __PACKAGE__->blockmods ){
        map { $BLOCKS{$_} ||= $module } $module->tags;
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
    use Data::Dumper;
    print Dumper(\%BLOCKS, $tag);
    
    if ( my $module = $BLOCKS{ $tag } ){
        eval{ $block = $module->_parse( $paragraph ) };
        if ($@){
            warn "parsing ==$command $tag block (line $line_num) failed. Error: $@";
        }
    }
    
    if ( $block ){
        push @{ $self->{_blocks}    ||=[] }, $block;
        push @{ $self->{_allblocks} ||=[] }, $block;
    }
    
}

sub preprocess_line{
    my ($self,$textline,$lineno) = @_;
    
    if ($textline =~ /\s*sub\s+(\w+)([^{]*){/ ){
        my ($method,$attr) = ($1,$2);
        
        print STDERR "LINE: $method, $attr\n";
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
    my ($parser, $paragraph, $line_num, $pod_para) = @_;
    #my $ptree = $parser->parse_text({%options}, $paragraph );
    #$pod_para->parse_tree( $ptree );
    #push @{ $self->{'-paragraphs'} }, $pod_para;
}

1;