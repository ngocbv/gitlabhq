# frozen_string_literal: true

class IssuePolicy < IssuablePolicy
  # This class duplicates the same check of Issue#readable_by? for performance reasons
  # Make sure to sync this class checks with issue.rb to avoid security problems.
  # Check commit 002ad215818450d2cbbc5fa065850a953dc7ada8 for more information.

  include CrudPolicyHelpers

  desc "User can read confidential issues"
  condition(:can_read_confidential) do
    @user && IssueCollection.new([@subject]).visible_to(@user).any?
  end

  desc "Issue is confidential"
  condition(:confidential, scope: :subject) { @subject.confidential? }

  desc "Issue has moved"
  condition(:moved) { @subject.moved? }

  rule { confidential & ~can_read_confidential }.policy do
    prevent(*create_read_update_admin_destroy(:issue))
    prevent :read_issue_iid
  end

  rule { ~can?(:read_issue) }.prevent :create_note

  rule { locked }.policy do
    prevent :reopen_issue
  end

  rule { ~can?(:read_issue) }.policy do
    prevent :read_design
    prevent :create_design
    prevent :destroy_design
  end

  rule { locked | moved }.policy do
    prevent :create_design
    prevent :destroy_design
  end
end

IssuePolicy.prepend_if_ee('EE::IssuePolicy')
