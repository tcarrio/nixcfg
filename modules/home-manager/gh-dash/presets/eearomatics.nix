{
  prSections = [
    {
      title = "[EE] PRs";
      filters = "is:open author:@me org:eearomatics sort:updated-desc";
    }
    {
      title = "[EE] Reviews";
      filters = "is:open review-requested:@me org:eearomatics sort:updated-desc";
    }
  ];
  issuesSections = [
    {
      title = "[EE] Assigned";
      filters = "is:open assignee:@me org:eearomatics sort:updated-desc";
    }
    {
      title = "[EE] Created";
      filters = "is:open author:@me org:eearomatics sort:updated-desc";
    }
  ];
}
