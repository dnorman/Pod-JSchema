package Pod::JSchema;

use Pod::JSchema::Parser;
use Moose;

has parser => (is => 'ro', default => sub { Pod::JSchema::Parser->new } );
has filename => (is => 'ro', required => 1);
has methods  => (is => 'rw');
has blocks   => (is => 'rw');
has show_all_methods => ( is => 'rw', default => 0 );
has render_header    => ( is => 'rw', default => 0 );
has snippet_only     => ( is => 'rw', default => 0 );
has css      => ( is => 'rw' );

sub BUILD{
    my $self = shift;
    $self->parser->parse_from_file( $self->filename );
    
    $self->methods( delete $self->parser->{_methods} || [] );
    $self->blocks( delete $self->parser->{_allblocks} || [] );
}

sub markdown{
    my $self = shift;
    
    
    my $out;
    if ($self->render_header){
        $out .= "## Methods\n\n";
    }
    
    foreach my $method (@{ $self->methods }){
        next unless $method->tags->{jschema} || $self->show_all_methods;
        $out .= $method->markdown;
    }

    return $out;
}

sub html{
     my $self = shift;
    
    my $out = '';
    
    if (! $self->snippet_only ){
        $out .= "<html>\n";
        $out .= '<head><link rel="stylesheet" href="' . $self->css . qq'" /></head>\n' if $self->css;
        $out .= "<body>\n";
    }
    $out .= '<div class="service">' . "\n";
    $out .= qq'<h2 class="methodheader header">Methods</h2>\n' if $self->render_header;
    
    foreach my $method (@{ $self->methods }){
        next unless $method->tags->{jschema} || $self->show_all_methods;
        $out .= $method->html;
    }

    $out .= "</div><!-- end service div -->\n";
    
    $out .= "<body></html>\n" unless $self->snippet_only;
    
    return $out;
}

1;
