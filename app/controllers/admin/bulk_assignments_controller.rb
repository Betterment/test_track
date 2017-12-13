class Admin::BulkAssignmentsController < AuthenticatedAdminController
  def new
    @split = Split.find params[:split_id]
    @bulk_assignment_creation = BulkAssignmentCreation.new
  end

  def create
    @split = Split.find params[:split_id]
    @bulk_assignment_creation = BulkAssignmentCreation.new(create_params)
    enqueue_assignments
  end

  private

  def enqueue_assignments
    if @bulk_assignment_creation.valid?
      BulkAssignmentJob.perform_later(create_params.to_h)
      flash[:success] = success_message
      redirect_to admin_split_path(@split)
    else
      flash[:error] = "Please address the errors below."
      render :new
    end
  end

  def success_message
    result = @bulk_assignment_creation
    "Enqueued job to assign visitors to #{@split.name}:#{result.variant} because #{result.reason}"
  end

  def create_params
    create_form_params.merge(admin: current_admin, split: @split)
  end

  def create_form_params
    params
      .require(:bulk_assignment_creation)
      .permit(:identifiers_listing, :identifier_type_id, :variant, :reason, :force_identifier_creation)
  end
end
