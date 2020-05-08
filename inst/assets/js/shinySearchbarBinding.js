var searchbar = new Shiny.InputBinding();

$.extend(searchbar, {
  find: function (scope) {
    return $(scope).find(".shiny-searchbar");
  },

  initialize: function (el) {
    var context = $(el).data("context");
    el.$context = $('#' + context);

    el.$searchbar = $(el).find("input[type='text']");
    el.$next = $(el).find("button[data-search='next']");
    el.$prev = $(el).find("button[data-search='prev']");

    $(el).data("matches", 0);
    $(el).data("current", $(el).data("cycler") ? 0 : null);
  },

  jump: function (el, $mark) {
    var $parent = $mark.parent();
    var parentOffset = $parent.offset();
    var markOffset = $mark.offset();

    // Calculate the vertical position for scrolling
    var markHeight = $mark.height();
    var toppos = $parent.scrollTop() + markOffset.top - parentOffset.top;
    toppos -= 1.5*markHeight; // Leave a small amount of vertical margin for context

    // Calculate the horizontal position for scrolling
    // Unlike the vertical position, this will only scroll if the mark is out of the parent window
    var parentWidth = $parent.outerWidth();
    var markWidth = $mark.width();
    var leftpos = $parent.scrollLeft() + markOffset.left - parentOffset.left;
    if ((leftpos + markWidth) > parentWidth) {
      leftpos -= (parentWidth - markWidth)/2; // Horizontally center the mark in the parent window
    } else {
      leftpos = 0;
    }

    $parent[0].scrollTo({
      left: leftpos,
      top: toppos,
      behavior: $(el).data("scroll-behavior")
    });
  },

  current: function (el, index) {
    if ($(el).data("matches") > 0) {
      var $results = el.$context.find("mark");
      var $mark = $results.eq(index);

      $results.removeClass("current");
      $mark.addClass("current");
      searchbar.jump(el, $mark);
    }
  },

  highlight: function (el) {
    var keyword = el.$searchbar.val();

    var opts = $.extend({},
      $(el).data("mark-options"), {
        "done": function (count) {
          // Store the total number of matches
          $(el).data("matches", count);
          // Reset the current index
          $(el).data("current", $(el).data("cycler") ? 0 : null);
        }
      }
    );

    el.$context.unmark({
      // Check for the iframes options or assign default value of 'false'
      iframes: opts.hasOwnProperty('iframes') ? opts.iframes : false,
      done: function () {
        el.$context.mark(keyword, opts);
      }
    });

    if ($(el).data("cycler")) {
      searchbar.current(el, $(el).data("current"));
    };
  },

  cycle: function (el, btn) {
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

  getValue: function (el) {
    return {
      "keyword": el.$searchbar.val(),
      "matches": $(el).data("matches"),
      "current": $(el).data("current")
    };
  },

  // getRatePolicy: function() {
  //   return {"policy": "debouncing", "delay": 10000};
  // },

  subscribe: function (el, callback) {
    el.$searchbar.on('input', function (event) {
      searchbar.highlight(el);
      callback();
    });

    if ($(el).data("cycler")) {
      el.$next.add(el.$prev).on('click', function (event) {
        if ($(el).data("matches")) {
          searchbar.cycle(el, this);
          callback();
        }
      });

      // Map the Enter and Shift+Enter keys to the next and prev buttons
      $(el).on('keypress', function (event) {
        // Enter key is 13
        if (event.which === 13 && event.shiftKey) {
          el.$prev.click();
        } else if (event.which === 13) {
          el.$next.click();
        };
      });

      // Block the enter key for incrementing the buttons when they're in focus
      el.$next.add(el.$prev).on('keypress', function (event) {
        event.preventDefault();
      });
    };
  }
});

Shiny.inputBindings.register(searchbar);