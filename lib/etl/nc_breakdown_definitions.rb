class NcBreakdownDefinitions
  def self.breakdown_lookup
    breakdown_hash = {
        'blck' => 3,
        'all' => 1,
        'amin' => 4,
        'asia' => 2,
        'lep' => 15,
        'not_lep' => 16,
        'fem' => 11,
        'paci' => 112,
        'hisp' => 6,
        'eds' => 9,
        'male' => 12,
        'mult' => 21,
        'swd' => 13,
        'not_swd' => 14,
        'not_mig' => 28,
        'mig' => 19,
        'whte' => 8,
        'aig' => 66
    }

    breakdown_hash
  end
end