(function() {
  var selectRadioButton = function (e) {
    var $button = $(this),
      $radioSet = $button.closest('[data-behavior~="radio"]'),
      $hiddenInput = $button.find('input'),
      name = $hiddenInput.attr('name'),
      $buttonsInGroup = $radioSet.find('input[name="' + name + '"]').closest('.radio-option');

    $hiddenInput.prop('checked', true).change();
    $buttonsInGroup.removeClass('selected');
    $button.addClass('selected');
  };

  $(document).on('click', '[data-behavior~="radio"] .radio-option:not(".disabled")', selectRadioButton);
  $(document).on('click', '[data-behavior~="radio"] .radio-options:not(".disabled") tr', selectRadioButton);

  $(document).on('click', '[data-behavior~="nested-radio"] li:not(".nested-radio-group")', function (e) {
    var $children = $(this).next('.nested-radio-group').find('li'),
      $adjacentSelectedButtons = $(this).siblings('li.selected');

    $children.first().click();

    $adjacentSelectedButtons.removeClass('selected');
    $adjacentSelectedButtons.find('input').prop('checked', false).change();
  });
}());
