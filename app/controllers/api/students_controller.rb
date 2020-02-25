class Api::StudentsController < ApplicationController
  SUPPORTED_GRADES = ['PK', 'KG', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12']

  before_action :require_login, only: [:show]

  def show
    render(status: :ok, json: { grades: current_user.map(&:grade) })
  end

  def create
    unless user
      render json: { errors: ['Must provide valid user email to add student grades'] }, status: 404
      return
    end

    if (SUPPORTED_GRADES & grades).blank?
      render json: { errors: ['No valid grades provided'] }, status: 404
      return
    end

    language = 'en' if language.blank?

    StudentGradeLevel.create_students(user.id, grades, state, language)
    render json: { errors: [] }, status: 200
  end

  def user
    User.find_by_email(params[:email])
  end

  def grades
    @_grades ||= (
      g = params['grades']
      if g.is_a?(String)
        g = g.split(',')
      end
      g
    )
  end

  def state
    params['state']
  end

  def language
    params['language']
  end
end
