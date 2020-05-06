var binding = new Shiny.InputBinding();
 
$.extend(binding, {
  find: function(scope) {
    return $(scope).find(".shiny-searchbar");
  },

  initialize: function(el) {
    // Default the number of matches to 0
    $(el).data("matches", 0);
  },

  getValue: function(el) {
    var keyword = el.value;
    var context = $(el).data("context");
    console.log(keyword, context)

    var $context = $('#' + context);
    console.log($context);

    var opts = {
      "done": function(count) {
        // Store the total number of matches
        $(el).data("matches", count);
      }
    };

    $context.unmark({
      done: function() {
        $context.mark(keyword, opts);
      }
    });

    return {"keyword": keyword, "matches": $(el).data("matches")};
  },

  // getRatePolicy: function() {
  //   return {"policy": "debouncing", "delay": 10000};
  // },

  subscribe: function(el, callback) {
    $(el).on('input', function (event) {
      callback();
    });
  }
});
 
Shiny.inputBindings.register(binding);