module SchoolTypeConcerns
  def decorated_school_type
    school_types_map = {
        charter: 'Public charter',
        public: 'Public district',
        private: 'Private'
    }
    school_types_map[type.to_s.downcase.to_sym]
  end
end