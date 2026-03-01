{
  prSections = [
    {
      title = "[SK] My PRs";
      filters = "is:open author:@me org:skillshare sort:updated-desc";
    }
    {
      title = "[SK] Needs Review";
      filters = "is:open review-requested:@me org:skillshare sort:updated-desc";
    }
    {
      title = "[SK] Open";
      filters = "is:open org:skillshare sort:updated-desc";
    }
  ];
  issuesSections = [
    {
      title = "[SK] Assigned";
      filters = "is:open assignee:@me org:skillshare sort:updated-desc";
    }
    {
      title = "[SK] Created";
      filters = "is:open author:@me org:skillshare sort:updated-desc";
    }
  ];
}
