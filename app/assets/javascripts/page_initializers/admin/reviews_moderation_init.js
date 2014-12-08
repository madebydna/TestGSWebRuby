if(gon.pagename == "Reviews moderation"){

    $(function () {

      var oTable = $('#flagged_reviews_table').dataTable({bFilter: false,
        bInfo: false, "pagingType": "simple_numbers","bLengthChange": false,
        'iDisplayLength': 50});

//      oTable.fnSort( [  [3,'asc'] ] );


    });
}