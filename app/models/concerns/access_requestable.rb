# == AccessRequestable concern
#
# Contains functionality related to objects that can receive request for access.
#
# Used by Project, and Group.
#
module AccessRequestable
  extend ActiveSupport::Concern

  def request_access(user)
    Members::RequestAccessService.new(self, user).execute
  end

  def approve_access_request(access_requester, user)
    Members::ApproveAccessRequestService.new(self, access_requester, user).execute
  end

  def withdraw_access_request(user)
    Members::DestroyAccessRequestService.new(self, user, user).execute
  end

  def deny_access_request(access_requester, user)
    Members::DestroyAccessRequestService.new(self, access_requester, user).execute
  end
end
