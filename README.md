Pod::JSchema

Inline service descriptions with the unholy marriage of Pod and JSON.

Why? Because Pod::WSDL sucks. (sorry, but it does)


Example:

    package MyModule;

    =head1 My Method
    
    Sample method to demonstrate Pod::JScema

    =for JSCHEMA {
        params: {
            some_list: [{
                some_id: "r+integer+ the letter r means required, notes go here",
                some_string: "string",
            }],
            some_hashref: { blah: "string+This is for something string-ey" }
        },
        returns: {
            success: "r:boolean",
            records: ["dt=record"]
        }
    }
    =cut
    
    sub mymethod{
      #...
    }
    1;


See bin/ directory for some ways to output html/markdown with MyModule.pm as an argument
