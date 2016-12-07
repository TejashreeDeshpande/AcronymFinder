//
//  ViewController.m
//  AcronymsFinder
//
//  Created by Tejashree Deshpande on 12/6/16.
//  Copyright © 2016 Tejashree Deshpande. All rights reserved.
//

#import "ViewController.h"
#import "Constants.h"
#import "WebServiceClient.h"
#import "MBProgressHUD.h"
#import "Acronym.h"
#import "Meaning.h"

@interface ViewController ()
@property (nonatomic, strong) Acronym *acronym;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *acronymTableView;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (nonatomic, strong) NSCharacterSet *disallowedCharacters;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.headerLabel.text = [NSString stringWithFormat:NSLocalizedString(@"HeaderLabelText", @""), self.headerLabel.text];
    
    [self resetContent];
    
    // Only alpha-numeric characters are allowed to enter in textfield. below set has the disallowed characters
    self.disallowedCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- UITableView Datasource methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.acronym.meanings.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *reuseIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    Meaning *meaning = [self.acronym.meanings objectAtIndex:indexPath.row];
    cell.textLabel.text = meaning.meaning;
    
    return cell;
}

#pragma mark - UITextField delegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // reset All content on screen when user starts entering any text
    [self resetContent];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Textfield is disabled till user enters atleast one character.
    // Dismiss Keyboard on return
    [textField resignFirstResponder];
    if(![textField.text isEqualToString:@""]){
        
        [self fetchMeaningsForAcronym:textField.text];
    }
    
    return YES;
    
}

/*
 * delegate checks the validity of user text  entry.
 * It checks for below 3 conditions
 * 1. If entered text is less than MAXLENGTH
 * (MAXLENGTH is set to 30. This value is configurable.)
 * 2. accept return key
 * 3. accept only alphabets and numeric characters.
 */

-(BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    
    return (newLength <= MAXLENGTH || ([string rangeOfString: @"\n"].location != NSNotFound)) && ([string rangeOfCharacterFromSet:self.disallowedCharacters].location == NSNotFound);
}

#pragma mark - Web service
-(void) fetchMeaningsForAcronym: (NSString *) acronym {
    
    NSDictionary *parameters = @{@"sf": acronym};
    
    // show loading indicator when web service is made
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[WebServiceClient sharedManager] getResponseForURLString:AIBaseURL
                                                  Parameters:parameters
                                                     success:^(NSURLSessionDataTask *task, Acronym *acronym) {
                                                         
                                                         // Stop progressbar
                                                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                         
                                                         self.acronym = acronym;
                                                         if (self.acronym && self.acronym.meanings.count > 0) {
                                                             [self.acronymTableView setHidden:NO];
                                                             [self.acronymTableView setContentOffset:CGPointZero animated:NO];
                                                             [self.acronymTableView reloadData];
                                                         }
                                                         else{
                                                             // show no results alerts
                                                             [self showErrorAlert:NSLocalizedString(@"NoResultsTitle", @"") message:[NSString stringWithFormat:NSLocalizedString(@"NoResultsMessage", @""),self.textField.text]];
                                                         }
                                                         
                                                     }
                                                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                         
                                                         // show error alert with error description
                                                         [self showErrorAlert:nil message:error.localizedDescription];
                                                         
                                                     }];
    
}

#pragma mark - Helper methods

-(void) resetContent{
    [self.acronymTableView setHidden:YES];
    self.acronym = nil;
}


#pragma mark - Error handling

-(void)showErrorAlert:(NSString *) title message:(NSString *) message{
    
    //Step 1: Create a UIAlertController
    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle: title
                                                                               message: message
                                                                        preferredStyle:UIAlertControllerStyleAlert                   ];
    
    //Step 2: Create a UIAlertAction that can be added to the alert
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             // dismiss the alertwindow
                             [myAlertController dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    //Step 3: Add the UIAlertAction ok that we just created to our AlertController
    [myAlertController addAction: ok];
    
    //Step 4: Present the alert to the user
    [self presentViewController:myAlertController animated:YES completion:nil];
}

@end
