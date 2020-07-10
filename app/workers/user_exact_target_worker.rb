class UserExactTargetWorker
  include Sidekiq::Worker

  SUBSCRIPTION_LISTS = %w(greatkidsnews greatnews osp sponsor teacher_list)
  SCHOOL_LISTS = %w(mystat mystat_private)

  def perform(user_id)
    user = User.find user_id
    ExactTarget::DataExtension.upsert('member', user)

    handle_subscriptions(user)
    handle_school_subscriptions(user)
    handle_gbg_subscriptions(user)
  end

  def handle_update(user, type, current_db_ids)
    current_et_ids = retrieve_current_et_subscriptions(type, user.id)

    ids_to_delete = current_et_ids - current_db_ids
    if ids_to_delete.any?
      puts "Deleting #{type} ids #{ids_to_delete}"
      ExactTarget::DataExtension.delete_multiple(type, ids_to_delete)
    end

    ids_to_create = current_db_ids - current_et_ids
    if ids_to_create.any?
      puts "Upserting #{type} ids #{ids_to_create}"
      yield ids_to_create
    end
  end

  def handle_subscriptions(user)
    puts "In handle subscriptions"
    current_ids = user.subscriptions.where(list: SUBSCRIPTION_LISTS).pluck(:id)
    handle_update(user, 'subscription', current_ids) do |ids_to_create|
      Subscription.where(id: ids_to_create).each do |sub|
        ExactTarget::DataExtension.upsert('subscription', sub)
      end
    end
  end

  def handle_gbg_subscriptions(user)
    puts "In handle gbg subscriptions"
    current_ids = user.student_grade_levels.pluck(:id)
    handle_update(user, 'grade-by-grade', current_ids) do |ids_to_create|
      StudentGradeLevel.where(id: ids_to_create).each do |sub|
        ExactTarget::DataExtension.upsert('grade-by-grade', sub)
      end
    end
  end

  def handle_school_subscriptions(user)
    puts "In handle school subscriptions"
    current_ids = user.subscriptions.where(list: SCHOOL_LISTS).pluck(:id)
    handle_update(user, 'school_subscription', current_ids) do |ids_to_create|
      Subscription.where(id: ids_to_create).each do |sub|
        ExactTarget::DataExtension.upsert('school_subscription', sub)
      end
    end
  end

  private

  def retrieve_current_et_subscriptions(type, user_id)
    current_subscriptions = ExactTarget::DataExtension.retrieve(type,
      { property: 'member_id', operator: 'equals', value: user_id },
      ['id'])
    current_subscriptions.map do |sub|
      sub['id'].to_i
    end
  end
end