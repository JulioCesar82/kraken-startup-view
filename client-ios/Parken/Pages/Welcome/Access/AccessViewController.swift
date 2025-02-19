import UIKit
import PhoneNumberKit
import FirebaseAuth

class AccessViewController: UIViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var forgetPasswordBtn: UIButton!
    
    @IBOutlet weak var instBtn: SecondButtonStyle!
    
    var emailTxt = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        emailTextField.placeholder = "Insira o seu e-mail..."
        emailTextField.autocorrectionType = .no
        emailTextField.text = emailTxt
        
        passwordTextField.placeholder = "Insira a sua senha..."
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocorrectionType = .no
        
    }
    
    @IBAction func signInClick(_ sender: Any) {
        
        guard let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty else{
                /*showEmptyDataAlert()*/
                return
            }
        
        if !validateEmail(emailTyped: email) {
            showEmptyDataAlert()
        } else {
            FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password , completion: { [weak self] result, error in
                       guard let strongSelf = self else{
                           return
                       }
                       guard error == nil else {
                           strongSelf.showEmptyDataAlert()
                           return
                       }
                       
                       print("Voce esta logado.")
                       
                       self?.performSegue(withIdentifier: "AccessToSignInSegue", sender: self)
                   })
        }

    }
    
    @IBAction func registerBtnClick(_ sender: Any) {
        self.performSegue(withIdentifier: "WelcomToRegisterSegue", sender: self)
    }
    
    @IBAction func forgetPasswordBtnClick(_ sender: Any) {
        self.performSegue(withIdentifier: "WelcomToUpdateSegue", sender: self)
    }
    
    @IBAction func instBtnClick(_ sender: Any) {
            performSegue(withIdentifier: "SignInToPresentationSegue", sender: nil)
        }
    
    func showEmptyDataAlert(){
        
        let alert = UIAlertController(title: "Dados incorretos", message: "Os dados inseridos estao incorretos", preferredStyle: .alert)
                  
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let signInView = segue.destination as? SignInViewController {
            signInView.phoneNumber = emailTextField.text!
        }
        
        if let signInView = segue.destination as? RegisterViewController {
            signInView.emailAddress = emailTextField.text!
            signInView.passwordTyped = passwordTextField.text!
        }
    }
    
    func validateEmail(emailTyped:String) -> Bool{
         let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
         let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
         return emailPredicate.evaluate(with: emailTyped)
     }
    
}
