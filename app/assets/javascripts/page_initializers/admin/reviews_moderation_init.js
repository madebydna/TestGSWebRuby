if(gon.pagename == "Reviews moderation"){

    $(function () {

      var oTable = $('#flagged_reviews_table').dataTable({bFilter: false,
        bInfo: false, "pagingType": "simple_numbers","bLengthChange": false,
        'iDisplayLength': 50});

//      oTable.fnSort( [  [3,'asc'] ] );



    $('input:checkbox').on('click', function() {
      var $this = $(this);
      var value = $this.prop('checked');
      var name = $this.attr('name');

      new_location = location.href.replace(new RegExp("&?" + name + "=([^&]$|[^&]*)", "i"), "");

      if (_.indexOf(new_location, '?') == -1) {
        new_location += '?';
      } else {
        new_location += '&';
      }
      location.href = new_location + name + "=" + value;
    });
  });
}