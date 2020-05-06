var searchbar = new Shiny.InputBinding();
 
$.extend(searchbar, {
  find: function(scope) {
    return $(scope).find(".shiny-searchbar");
  },

  initialize: function(el) {
    el.$searchbar = $(el).find("input[type='text']");
    el.$next = $(el).find("button[data-search='next']");
    el.$prev = $(el).find("button[data-search='prev']");
    
    var context = $(el).data("context");
    el.$context = $('#' + context);

    el.cycler = $(el).data("cycler") == "TRUE" ? true : false

    $(el).data("matches", 0);
    $(el).data("current", el.cycler ? 0 : null);
  },

  current: function(el, index) {
    var $results = el.$context.find("mark");

    $results.removeClass("current");
    $results.eq(index).addClass("current");
  },

  highlight: function(el) {
    var keyword = el.$searchbar.val();

    var opts = {
      "done": function(count) {
        // Store the total number of matches
        $(el).data("matches", count);
        // Reset the current index
        $(el).data("current", el.cycler ? 0 : null);
      }
    };

    el.$context.unmark({
      done: function() {
        el.$context.mark(keyword, opts);
      }
    });

    if (el.cycler) {
      searchbar.current(el, $(el).data("current"));
    };
  },

  cycle: function(el, btn) {
    var index = $(el).data("current");
    var total = $(el).data("matches");

    // Increment the counter based on the button pressed
    index += $(btn).is(el.$next) ? 1 : -1;

    // Roll the index over when it goes below 0
    if (index < 0) {
      index = total - 1;
    }

    // Reset the index when it exceeds the total number of matches (minus 1, of course)
    if (index > total - 1) {
      index = 0
    }

    searchbar.current(el, index);
    $(el).data("current", index);
  },

  getValue: function(el) {
    return {
      "keyword": el.$searchbar.val(),
      "matches": $(el).data("matches"),
      "current": $(el).data("current")
    };
  },

  // getRatePolicy: function() {
  //   return {"policy": "debouncing", "delay": 10000};
  // },
 
  subscribe: function(el, callback) {
    el.$searchbar.on('input', function (event) {
      searchbar.highlight(el);
      callback();
    });

    if (el.cycler) {
      el.$next.add(el.$prev).on('click', function (event) {
        if ($(el).data("matches")) {
          searchbar.cycle(el, this);
          callback();
        }
      });
    }
  }
});
 
Shiny.inputBindings.register(searchbar);