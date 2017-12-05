class NcBreakdownDefinitions
  def self.breakdown_lookup
    breakdown_hash = {
        'BLCK' => 3,
        'ALL' => 1,
        'AMIN' => 4,
        'ASIA' => 2,
        'LEP' => 15,
        'NOT_LEP' => 16,
        'FEM' => 11,
        'PACI' => 112,
        'HISP' => 6,
        'EDS' => 9,
        'MALE' => 12,
        'MULT' => 21,
        'SWD' => 13,
        'NOT_SWD' => 14,
        'NOT_MIG' => 28,
        'MIG' => 19,
        'WHTE' => 8,
        'AIG' => 66
    }

    breakdown_hash
  end
end