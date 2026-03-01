{
  prSections = [
    {
      title = "[All] My PRs";
      filters = "is:open author:@me sort:updated-desc";
    }
    {
      title = "[All] Reviews";
      filters = "is:open review-requested:@me sort:updated-desc";
    }
  ];
  issuesSections = [
    {
      title = "[All] Assigned";
      filters = "is:open assignee:@me sort:updated-desc";
    }
  ];
}
