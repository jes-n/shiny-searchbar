/**
 * Perform the text highlighting using mark.js
 * @param {HTMLElement} el The searchbar input binding element.
 */
function highlight(el) {
  const keyword = el.$searchbar.val();

  const opts = {
    ...$(el).data("mark-options"),
    "done": function (count) {
      // Store the total number of matches
      $(el).data("matches", count);
      // Reset the current index
      $(el).data("current", $(el).data("cycler") ? 0 : null);
    },
  };
  
  el.$context.unmark({
    // Check for the iframes options or assign default value of 'false'
    iframes: opts.hasOwnProperty('iframes') ? opts.iframes : false,
    done: function () {
      el.$context.mark(keyword, opts);
    }
  });

  if ($(el).data("cycler")) current(el, $(el).data("current"));
  if ($(el).data("counter")) counter(el);
};


/**
 * Updates the search bar counter
 * @param {HTMLElement} el The searchbar input binding element.
 */
function counter(el) {
  let msg;

  // Remove classes
  el.$counter.removeClass("nomatch match");

  // No user input
  if (el.$searchbar.val().length == 0) {
    msg = null;

  // No matches to user input
  } else if ($(el).data("matches") == 0) {
    el.$counter.addClass("nomatch");
    msg = "No matches";

  // Matches found, check if cycler enabled
  } else {
    el.$counter.addClass("match");
    if ($(el).data("cycler")) {
      msg = $(el).data("current") + 1 + " of " + $(el).data("matches");
    } else {
      msg = $(el).data("matches") + " matches";
    }
  }

  el.$counter.text(msg);
};


/**
 * Scrol to the currently highlighted mark element.
 * 
 * This works in either an overflow element or the window itself.
 * 
 * @param {HTMLElement} el The searchbar input binding element.
 * @param {jQuery} $mark The mark element that is currently highlighted.
 */
function jump(el, $mark) {
  let parent = $mark.parent().get(0);

  const markOffset = $mark.offset();
  const markHeight = $mark.height();
  const markWidth = $mark.width();

  // The method of scrolling depends on if the parent element has overflow
  let parentWidth;
  if (parent.offsetHeight < parent.scrollHeight || parent.offsetWidth < parent.scrollWidth) {
    parentWidth = $(parent).outerWidth();
    const parentOffset = $(parent).offset();

    let parentTop = $(parent).scrollTop();
    let parentLeft = $(parent).scrollLeft();

    // Calculate the vertical and horizontal positions for scrolling
    toppos = parentTop + markOffset.top - parentOffset.top;
    leftpos = parentLeft + markOffset.left - parentOffset.left;

  } else {
    parentWidth = window.innerWidth;

    // Simply set the vertical and horizontal positions, based on the mark
    toppos = markOffset.top;
    leftpos = markOffset.left;
    
    // Set the parent to the window element for scrolling
    parent = window;
  }

  // Add a small amount of vertical space for context
  toppos -= 1.5*markHeight;

  // Unlike the vertical position, the horizontal position will only scroll if the mark is out of the window
  if ((leftpos + markWidth) > parentWidth) {
    leftpos -= (parentWidth - markWidth)/2; // Horizontally center the mark in the parent window
  } else {
    leftpos = 0;
  }

  parent.scrollTo({
    left: leftpos,
    top: toppos,
    behavior: $(el).data("scroll-behavior")
  });
};

/**
 * Denote the currently highlighted mark element and scroll to it
 * @param {HTMLElement} el The searchbar input binding element.
 * @param {!int} index Index of the currently highlighted mark within the
 *     results array.
 */
function current(el, index) {
  if ($(el).data("matches") > 0) {
    const $results = el.$context.find("mark");
    const $mark = $results.eq(index);

    $results.removeClass("current");
    $mark.addClass("current");
    jump(el, $mark);
  }
  $(el).data("current", index);
};

/**
 * Cycle between all the matches, if the cycler is enabled
 * @param {HTMLElement} el The searchbar input binding element.
 * @param {!HTMLButtonElement} btn The button that was pressed to execute
 *     the next cycle.
 */
function cycle(el, btn) {
  const total = $(el).data("matches");
  let index = $(el).data("current");

  // Increment the counter based on the button pressed
  index += $(btn).is(el.$next) ? 1 : -1;

  // Roll the index over when it goes below 0
  if (index < 0) index = total - 1;

  // Reset the index when it exceeds the total number of matches (minus 1, of course)
  if (index > total - 1) index = 0;

  current(el, index);
  if ($(el).data("counter")) counter(el);
};


const searchbar = new Shiny.InputBinding();

$.extend(searchbar, {
  find: function (scope) {
    return $(scope).find(".shiny-sb");
  },

  initialize: function (el) {
    const context = $(el).data("context");
    el.$context = $('#' + context);

    el.$searchbar = $(el).find("input[type='text']");
    el.$next = $(el).find("button[data-search='next']");
    el.$prev = $(el).find("button[data-search='prev']");
    el.$counter = $(el).find("small[data-search='counter']");

    $(el).data("matches", 0);
    $(el).data("current", $(el).data("cycler") ? 0 : null);

    // Initialize any default value
    if (el.$searchbar.val()) highlight(el);
  },

  getValue: function (el) {
    return {
      "keyword": el.$searchbar.val(),
      "matches": $(el).data("matches"),
      "current": $(el).data("current"),
    };
  },

  // getRatePolicy: function() {
  //   return {"policy": "debouncing", "delay": 10000};
  // },

  subscribe: function (el, callback) {
    el.$searchbar.on('input', function (event) {
      highlight(el);
      callback();
    });

    if ($(el).data("cycler")) {
      el.$next.add(el.$prev).on('click', function (event) {
        if ($(el).data("matches")) {
          cycle(el, this);
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
        }
      });

      // Block the enter key for incrementing the buttons when they're in focus
      el.$next.add(el.$prev).on('keypress', function (event) {
        event.preventDefault();
      });
    }
  }
});

Shiny.inputBindings.register(searchbar);


/**
 * Update the 'mark-options' data attribute of an already initialized
 * search bar widget element.
 * @param {object} message Widget's `id` and new `markOpts`
 */
function updateMarkOptions(message) {
  const $el = $(document).find("#" + message['id']);

  $el.data("mark-options", {
    ...$el.data("mark-options"),
    ...message['markOpts'],
  });

  highlight($el.get(0));
};

Shiny.addCustomMessageHandler("updateMarkOptions", updateMarkOptions);
