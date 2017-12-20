module SupervisorReportsHelper
  def human_name(name)
    t name, scope: %i[activerecord attributes supervisor_report]
  end
end
