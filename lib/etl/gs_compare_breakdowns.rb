
class GsCompareBreakdowns


    @h1 = {
        '1' => 1,
        '3' => 13,
        '4' => 11,
        '160' => 15,
        '28' => 19,
        '31' => 9,
        '111' => 10,
        '128' => 13,
        '99' => 14,
        '74' => 3,
        '75' => 4,
        '77' => 5,
        '78' => 6,
        '80' => 8,
        '76' => 2,
        '79' => 112,
        '144' => 21
    }
    @h2 = {
        '1' => 1,
        '3' => 13,
        '4' => 11,
        '160' => 15,
        '28' => 19,
        '31' => 9,
        '111' => 10,
        '128' => 13,
        '99' => 14,
        '74' => 3,
        '75' => 4,
        '77' => 5,
        '78' => 6,
        '80' => 8,
        '76' => 2,
        '79' => 112,
        '144' => 21
    }



    # if (@hash1.size > @hash2.size)
    #   difference = @hash1.to_a - @hash2.to_a
    # else
    #   difference = @hash2.to_a - @hash1.to_a
    # end

    # result = Hash[*difference.flatten]

     result = (@h1.keys & @h2.keys).each {|k| puts ( @h1[k] == @h2[k] ? @h1[k] : k ) }

    puts result


end