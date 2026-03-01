{
  prSections = [
    {
      title = "[OF] My PRs";
      filters = "is:open author:@me org:open-feature sort:updated-desc";
    }
    {
      title = "[OF] Reviews";
      filters = "is:open review-requested:@me org:open-feature sort:updated-desc";
    }
  ];
  issuesSections = [
    {
      title = "[OF] Assigned";
      filters = "is:open assignee:@me org:open-feature sort:updated-desc";
    }
    {
      title = "[OF] Created";
      filters = "is:open author:@me org:open-feature sort:updated-desc";
    }
  ];
}
