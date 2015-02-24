//
//  MCTConsoleViewController.m
//  BLECM-DevKit
//
//  Created by Joel Garrett on 7/16/14.
//  Copyright (c) 2014 Microchip Technology Inc. and its subsidiaries.
//
//  You may use this software and any derivatives exclusively with Microchip products.
//
//  THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER EXPRESS,
//  IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED WARRANTIES
//  OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A PARTICULAR PURPOSE, OR
//  ITS INTERACTION WITH MICROCHIP PRODUCTS, COMBINATION WITH ANY OTHER PRODUCTS, OR
//  USE IN ANY APPLICATION.
//
//  IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
//  INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND WHATSOEVER
//  RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS BEEN ADVISED OF
//  THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE FULLEST EXTENT ALLOWED
//  BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN ANY WAY RELATED TO THIS
//  SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY, THAT YOU HAVE PAID DIRECTLY
//  TO MICROCHIP FOR THIS SOFTWARE.
//
//  MICROCHIP PROVIDES THIS SOFTWARE CONDITIONALLY UPON YOUR ACCEPTANCE OF THESE
//  TERMS.
//

#import "MCTConsoleViewController.h"
#import "MCTDrawerViewController.h"
#import "MCTConsoleMonitor.h"
#import "MCTConsoleCell.h"
#import "MCTRequestSummary.h"
#import <MessageUI/MessageUI.h>

@interface MCTConsoleViewController () <MFMailComposeViewControllerDelegate, MCTConsoleMonitorDelegate>

@property (nonatomic, strong) MCTConsoleMonitor *consoleMonitor;
@property (nonatomic, strong) MCTConsoleCell *prototypeCell;
@property (nonatomic, strong) NSCache *summaryCache;
@property (nonatomic, strong) NSIndexPath *deletedIndexPath;
@property (nonatomic, readwrite) NSUInteger displayedCount;

@end

@implementation MCTConsoleViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[self consoleMonitor] stopMonitoring];
}

- (void)awakeFromNib
{
    [self setupNotifications];
    [self setSummaryCache:[NSCache new]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupConsoleViewController];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[self tableView] reloadData];
    [[self consoleMonitor] startMonitoring];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self consoleMonitor] stopMonitoring];
}

- (void)setupConsoleViewController
{
    MCTAppearance *appearance = [MCTAppearance appearance];
    [[self clearConsoleButtonItem] setTintColor:appearance.buttonTextColor];
    [self setupTableView];
    [self setupConsoleMonitor];
}

- (void)setupTableView
{
    MCTAppearance *appearance = [MCTAppearance appearance];
    [[self tableView] setScrollsToTop:YES];
    [[self tableView] setBackgroundColor:appearance.primaryTextColor];
    [[self tableView] setSeparatorColor:UIColor.darkGrayColor];
    [[self tableView] registerNib:[MCTConsoleCell mct_nib]
           forCellReuseIdentifier:[MCTConsoleCell mct_reuseIdentifier]];
    [[self tableView] setTableFooterView:[UIView new]];
}

- (void)setupConsoleMonitor
{
    MCTConsoleMonitor *monitor = [MCTConsoleMonitor new];
    [monitor setDelegate:self];
    [self setConsoleMonitor:monitor];
}

- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(drawerViewWillOpenNotification:)
                                                 name:MCTDrawerViewControllerWillOpenNotification
                                               object:nil];
}

#pragma mark - Control events

- (IBAction)clearConsoleBarButtonPressed:(id)sender
{
    [MCTRequestSummary clearHistory];
}

- (MCTRequestSummary *)summaryAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *filePath = [[self consoleMonitor] filePathAtIndexPath:indexPath];
    MCTRequestSummary *summary = [[self summaryCache] objectForKey:indexPath];
    if (summary == nil)
    {
        summary = [MCTRequestSummary summaryWithContentsOfFile:filePath];
    }
    return summary;
}

- (void)configureCell:(MCTConsoleCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MCTRequestSummary *summary = [self summaryAtIndexPath:indexPath];
    NSString *title = [NSString stringWithFormat:@"%@: %@",
                       summary.request.HTTPMethod,
                       summary.request.URL.absoluteString];
    [[cell requestLabel] setText:title];
    
    MCTAppearance *appearance = [MCTAppearance appearance];
    if (summary.responseError)
    {
        [[cell statusImageView] setTintColor:appearance.errorStatusColor];
        if (summary.responseString.length)
        {
            [[cell responseLabel] setText:summary.responseString];
        }
        else
        {
            NSError *error = summary.responseError;
            [[cell responseLabel] setText:error.localizedDescription];
        }
    }
    else
    {
        [[cell statusImageView] setTintColor:appearance.successStatusColor];
        if ([summary.request.HTTPMethod isEqualToString:@"POST"]){
            [[cell responseLabel] setText:summary.requestString];
        } else {
            [[cell responseLabel] setText:summary.responseString];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.displayedCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[MCTConsoleCell mct_reuseIdentifier]
                                                            forIndexPath:indexPath];
    [self configureCell:(MCTConsoleCell *)cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self setDeletedIndexPath:indexPath];
        MCTRequestSummary *summary = [self summaryAtIndexPath:indexPath];
        [summary deleteSummary];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.prototypeCell == nil)
    {
        NSString *identifier = [MCTConsoleCell mct_reuseIdentifier];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        [self setPrototypeCell:(MCTConsoleCell *)cell];
    }
    
    [self configureCell:self.prototypeCell atIndexPath:indexPath];
    [[self prototypeCell] layoutIfNeeded];
    UIView *contentView = [[self prototypeCell] contentView];
    CGSize size = [contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return (size.height + 16.0);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Compose an email of the selected request summary.
    MCTRequestSummary *summary = [self summaryAtIndexPath:indexPath];
    NSString *messageBody = [summary HTMLSummary];
    MFMailComposeViewController *controller = [MFMailComposeViewController new];
    [controller setMailComposeDelegate:self];
    [controller setSubject:@"BLECM request summary"];
    [controller setMessageBody:messageBody isHTML:YES];
    [self presentViewController:controller
                       animated:YES
                     completion:nil];
    
    NSMutableDictionary *segmentation = [NSMutableDictionary new];
    [segmentation setValue:summary.request.HTTPMethod
                forKeyPath:@"Method"];
    [segmentation setValue:summary.responseError.description
                    forKey:@"Error"];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES
                                   completion:nil];
}

#pragma mark - Drawer view notifications

- (void)drawerViewWillOpenNotification:(NSNotification *)notification
{
    [[self tableView] setScrollsToTop:YES];
}

#pragma mark - MCTConsoleMonitorDelegate

- (void)consoleMonitorDidChangeContent:(MCTConsoleMonitor *)consoleMonitor
{
    NSInteger count = consoleMonitor.filePaths.count;
    if (self.deletedIndexPath)
    {
        [self setDisplayedCount:count];
        [[self tableView] deleteRowsAtIndexPaths:@[self.deletedIndexPath]
                                withRowAnimation:UITableViewRowAnimationAutomatic];
        [self setDeletedIndexPath:nil];
    }
    else
    {
        if (count == (self.displayedCount + 1))
        {
            [self setDisplayedCount:count];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            [[self tableView] insertRowsAtIndexPaths:@[indexPath]
                                    withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else
        {
            [self setDisplayedCount:count];
            [[self tableView] reloadData];
        }
    }
}

@end
