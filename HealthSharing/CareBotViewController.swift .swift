import UIKit

class CareBotViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.97, green: 0.98, blue: 1.0, alpha: 1.0)
        title = "CareBot"
        setupChatUI()
    }

    func setupChatUI() {

        let container = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        container.layer.cornerRadius = 28
        container.clipsToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)

        let inputField = UITextField()
        inputField.placeholder = "Type here..."
        inputField.font = UIFont.systemFont(ofSize: 16)
        inputField.translatesAutoresizingMaskIntoConstraints = false

        let sendButton = UIButton(type: .system)
        sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton.tintColor = .black
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        container.contentView.addSubview(inputField)
        container.contentView.addSubview(sendButton)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            container.heightAnchor.constraint(equalToConstant: 64),

            inputField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            inputField.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            sendButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            sendButton.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }
}
