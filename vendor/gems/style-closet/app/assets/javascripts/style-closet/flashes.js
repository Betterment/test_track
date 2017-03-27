(function() {
  $(document).on('click', '.sc-flash [data-behavior~="close-flash"]', function(e) {
    var $flash = $(e.target).closest('.sc-flash');

    $flash.hide();
  });
}());
