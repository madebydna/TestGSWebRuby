if(gon.pagename == "Reviews moderation list"){

    $(function () {

      if(gon.flagged_reviews_count != undefined && gon.flagged_reviews_count <= 150) {

        var oTable = $('.flagged_reviews_table').dataTable({bFilter: false,
          bInfo: false, "pagingType": "simple_numbers","bLengthChange": false,
          'iDisplayLength': 50});

//      oTable.fnSort( [  [3,'asc'] ] );

      }

    $('input:checkbox').on('click', function() {
      var $this = $(this);
      var value = $this.prop('checked');
      var name = $this.attr('name');

      newLocation = location.href.replace(new RegExp("&?" + name + "=([^&]$|[^&]*)", "i"), "");

      if (_.indexOf(newLocation, '?') == -1) {
        newLocation += '?';
      } else {
        newLocation += '&';
      }
      location.href = newLocation + name + "=" + value;
    });
  });
}