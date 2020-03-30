/*///////////////////////
http://stackoverflow.com/questions/11523331/passing-variables-through-handlebars-partial

Adds support for passing arguments to partials. Arguments are merged with 
the context for rendering only (non destructive). Use `:token` syntax to 
replace parts of the template path. Tokens are replace in order.

USAGE: {{$ 'path.to.partial' context=newContext foo='bar' }}
USAGE: {{$ 'path.:1.:2' replaceOne replaceTwo foo='bar' }}
Options in hash?
{{hash.foo}}
///////////////////////////////*/

Handlebars.registerHelper('$', function(partial) {
    var values, opts, done, value, context;
    if (!partial) {
        console.error('No partial name given.');
    }
    values = Array.prototype.slice.call(arguments,1);
    opts = values.pop();
    while (!done) {
        value = values.pop();
        if (value) {
            partial = partial.replace(/:[^\.]+/, value);
        }
        else {
            done = true;
        }
    }
  
    //partial = Handlebars.partials[partial];
    partial = HandlebarsTemplates[partial];
    if (!partial) {
        return '';
    }
    context = _.extend({}, opts.context||this, _.omit(opts, 'context', 'fn', 'inverse'));
    //console.log(context)
    return new Handlebars.SafeString( partial(context) );
});