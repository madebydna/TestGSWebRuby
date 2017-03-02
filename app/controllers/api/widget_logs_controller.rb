class Api::WidgetLogsController < ApplicationController

  def create
    if widget_log_from_params.save
      render json: { errors: [] }, status: :ok
    else
      GSLogger.error(:misc, nil, vars: params, message: 'Something went wrong recording widget log')
      render json: { errors: ['Something went wrong recording widget log'] }, status: :unprocessable_entity
    end
  rescue => e
    GSLogger.error(:misc, e, vars: params, message: 'Something went wrong recording widget log')
    render json: { errors: ['Something went wrong recording widget log'] }, status: :unprocessable_entity
  end

  def widget_log_from_params
    @_widget_log_from_params ||= WidgetLog.new(widget_params)
  end

  def widget_params
    params.require(:widget).permit(:email, :target_url)
  end
end
