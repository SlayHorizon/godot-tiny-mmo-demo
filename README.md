# Godot Tiny MMO Template

This repository contains a minimalistic MMO template built using the Godot Engine 4.3.  
The project adheres to GDScript guidelines.

## Project Goals / To-Do List

This project aims to create a minimalist functional MMO-style game with the following features.  
The list below indicates the current progress:

- [x] **Client-Server connection through WebSocketMultiplayerPeer.**
- [ ] **Client side working on web browser.**
- [x] **Authentication steps before connecting.**
- [ ] **Login UI to authenticate.** 
- [x] **Synchronizing entities among the players in the same instance.**
- [x] **Hosting different map instances on a single server and allowing traveling between them.**
- [ ] **Simple combat system with PvE and PvP**
- [ ] **Private instance for individual players or groups**  
- [ ] **Inventory system**  

See the [open issues](https://github.com/SlayHorizon/godot-tiny-mmo-template/issues) for a full list of proposed features (and known issues).  

## Getting Started

To get started with the project:
1. Clone this repository.
2. Launch it with Godot 4.3.
3. In Debug tab, choose "Customizable Run Instance...".
4. Enable Multiple Instances and set 3.
5. Under feature tags, be sure to have 2 "client" and 1 "server.
6. Play the project.

## Contributing

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Contributors
<a href = "https://github.com/SlayHorizon/simple-sqlite/graphs/contributors">
  <img src = "https://contrib.rocks/image?repo=SlayHorizon/godot-tiny-mmo-template"/>
</a>  

Also thanks to [@Anokolisa](https://anokolisa.itch.io/dungeon-crawler-pixel-art-asset-pack) for allowing us to use its assets for an open source project!
