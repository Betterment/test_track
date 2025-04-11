class AdminSplitAssignmentsPage < SitePrism::Page
  set_url "/admin/splits/{split_id}/assignments"

  elements :assignments, ".AdminSplitAssignments--index table tbody tr"
end
