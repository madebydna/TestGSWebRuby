module OptimizelyConcerns

  protected
  def set_optimizely_gon_env_value
    gon.optimizely_key = ENV_GLOBAL['optimizely_key']
  end

  def set_optimizely_instance_var
    @optimizely_key = ENV_GLOBAL['optimizely_key']
  end
end
