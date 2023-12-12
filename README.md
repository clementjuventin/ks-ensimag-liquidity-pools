# Pools de liquidité - #W3 KS Ensimag

## Introduction

Aujourd'hui et à l'occasion de cette découverte de la DeFi (Decentralized Finance), nous allons vous présenter les pools de liquidité.

Pendant ce workshop vous devrez donc compléter un smart contract minimaliste d'une pool de liquidité. L'important n'est pas tant de réussir que de comprendre le fonctionnement des pools de liquidité, n'hésitez à pas poser des questions pour ne pas trop perdre de temps sur l'implémentation.

Nous allons aussi utiliser un environnement de développement différent des autres workshops. Il s'agit de l'environnement `Foundry`.

Comme cité dans le [Foundry book](https://book.getfoundry.sh/):

```
Foundry is a smart contract development toolchain.

Foundry manages your dependencies, compiles your project, runs tests, deploys, and lets you interact with the chain from the command-line and via Solidity scripts.
```

## Installation

Pour installer Foundry, vous pouvez suivre le [guide d'installation](https://book.getfoundry.sh/getting-started/installation#using-foundryup).

Nous conseillons d'utiliser `Foundryup`.

Par défaut, vous disposerez de ces quatre bibliothèques:

- `forge` : Permet de tester, build, déployer vos smarts contracts
- `cast` : Permet d'interragir avec des contrats déployés
- `anvil` : Il s'agit d'un local testnet, c'est une blockchain hébergée sur votre ordinateur ou un serveur, pratique pour tester et brancher un frontent sur vos applications
- `chisel` : Outil dédié au test des SM

Une fois Foundry installé, vous pouvez vous rendre dans le dossier `/contracts` et tester de build le projet avec:

`forge build`

## Architecture

Voici le contenu du dossier `\contract`.

```
.
├── foundry.toml
├── lib
|   └── ...
├── src
│   ├── Context.sol
│   ├── ERC20.sol
│   ├── interfaces
│   │   ├── IERC20Metadata.sol
│   │   ├── IERC20.sol
│   │   └── ILiquidityPool.sol
│   └── LiquidityPool.sol
└── test
    └── LiquidityPool.t.sol
```

`foundry.toml` - paramétrage du projet foundry

`lib` - contient les dépendances du projet. On peut par exemple demander à forge d'installer les contrats _OpenZeppellin_. En l'occurence il n'y pas de dépendance explicite, vous trouverez dans le package `forge-std` des fonctions utiles à utiliser dans vos contrats -comme `console.log(..)`.

`src` - contient les contrats que vous avez codé. On peut déjà trouver quelques contrats comme vous pouvez le constater, l'important est ici de se concentrer sur `LiquidityPool.sol`. Il s'agit du contrat que vous allez devoir compléter et qui implémente l'interface `ILiquidityPool.sol`.

`test` - contient les tests du contrat `LiquidityPool.sol`.

## Implémentation

Comme énoncé, l'objectif va être d'implémenter l'interface `ILiquidityPool.sol`.

Nous vous invitons à consulter le fichier en question pour découvrir les spécifications des méthodes. Nous proposons aussi un ordre et des indications supplémentaires dans ce readme.

### Ajout de liquidité

Pour que la pool dispose de liquidité, il faut ajouter une quantité de tokenA et de tokenB. Pour se faire, nous avons besoin d'une fonction que transfert un certain nombre de tokens depuis un utilisateur vers le smart contract `LiquidityPool`.

```
/**
 * @dev Ajoute de la liquidité à la pool.
 * @param _token Le token à ajouter.
 * @param _amount Le montant à ajouter.
 * @custom:throws InvalidToken Si le token n'est pas dans la pool.
 */
function addLiquidity(address _token, uint256 _amount) external;
```

En eximinant le prototype de la méthode `addLiquidity` on déduit que:

- On doit tester que le token passé en argument pour savoir si il correspond à la définition de cette pool de liquidité.
  Le contrat déclare une erreur `InvalidToken` prévue à cet effet.

```
    /!\ Hint - Pour déclancher une exception et bloquer l'exécution d'un smart contract on utilise:
    revert ExceptionName();
```

- On doit transférer les fonds depuis l'utilisateur vers le smart contract. Pour obtenir l'addresse du smart contract dans lequel on s'exécute on utilise `address(this)` et pour obtenir l'addresse de la personne qui appelle le SM on fait `msg.sender`.

```
    /!\ Hint - Pour effectuer un transfert de token, on doit manipuler un ERC20. Ici on dispose seulement de l'addresse du token. Il va donc falloire le caster:
    IERC20 erc20Token = IERC20(tokenAddress);
```

```
    /!\ Hint - Les prototypes des méthodes permettant un transfert de token ERC20 sont:
    transfer(address recipient, uint256 amount) → bool
    transferFrom(address sender, address recipient, uint256 amount) → bool
```

- Incrémenter les compteurs de liquidité présents dans le SM (`aLiquidity`, `bLiquidity`).

### Getters

```
/**
 * @dev Retourne la liquidité disponible dans la pool.
 * @param _token Le token dont on souhaite connaitre la liquidité.
 * @return _ La liquidité disponible.
 * @custom:throws InvalidToken Si le token n'est pas dans la pool.
 */
function getLiquidity(address _token) external view returns (uint256);
/**
 * @dev Retourne l'adresse du token A.
 */
function getTokenA() external view returns (address);
/**
 * @dev Retourne l'adresse du token B.
 */
function getTokenB() external view returns (address);
```

EZ.

### Rate

```
/**
 * @dev Retourne le taux de change entre les deux tokens.
 * @param _token Le token à échanger.
 * @param _amount Le montant à échanger.
 * @return _ Le taux de change et le slippage.
 * @custom:throws InvalidToken Si le token n'est pas dans la pool.
 * @custom:throws InsuffisantLiquidity Si la pool n'a pas assez de liquidité.
 */
function rate(
    address _token,
    uint256 _amount
) external view returns (uint256, uint256);
```

`rate` doit retourner le taux proposé ainsi que le slippage.

Pour rappel:

- _slippage_ - le slippage représente l'écart entre le prix attendu et le prix réel ou l'échange se produit. Ici, il ne s'agit pas d'un vrai slippage mais plutôt d'un indicateur qui permet de voir à quel point le swap effectué va affecter la pool.

Exemple: On a le taux suivant 1:3 (1 token A contre 3 token B), si je souhaite échanger 1000 token A contre X token B, je vais augmenter le nombre de A et baisser le nombre de B. Ainsi, je change le rapport A:B. Disons que le nouveau rapport est 1.002:3, j'ai donc fait évoluer le prix de A de 1/3B à 1.002/3B pour 1A, soit 0.2%. Le slippage est de 0.2%.

Ici, nous vous donnons la fonction `rate` parce que c'est des mathématiques. Sachez par ailleur que cette fonction de rate est vraiment nulle.

```
function rate(
    address _token,
    uint256 _amount
) external view returns (uint256, uint256) {
    if (_token != tokenA && _token != tokenB) {
        revert InvalidToken();
    }
    if (aLiquidity == 0 || bLiquidity == 0) {
        revert InsuffisantLiquidity();
    }
    uint256 ratio = (aLiquidity * 1e18) / bLiquidity;
    uint256 next_ratio;
    uint256 swapRate;
    uint256 slippage;
    uint256 expected_amount_out = (ratio * _amount) / 1e18;
    if (_token == tokenA) {
        if (expected_amount_out > bLiquidity) {
            revert InsuffisantLiquidity();
        }
        next_ratio =
            ((aLiquidity + _amount) * 1e18) /
            (bLiquidity - expected_amount_out);
        swapRate = (next_ratio - ratio) / 2 + ratio;
        slippage = ((swapRate - ratio) * 1e18) / ratio;
    } else {
        if (expected_amount_out > aLiquidity) {
            revert InsuffisantLiquidity();
        }
        next_ratio =
            ((aLiquidity - expected_amount_out) * 1e18) /
            (bLiquidity + _amount);
        swapRate = (ratio - next_ratio) / 2 + next_ratio;
        slippage = ((ratio - swapRate) * 1e18) / ratio;
    }
    return (swapRate, slippage);
}
```

### Swap

La fonction la plus longue à implémenter, mais elle sera relativement simple.

```
/**
 * @dev Echange une quantité de token A contre une quantité de token B.
 * @param _fromToken Le token à échanger.
 * @param _amountIn Le montant à échanger.
 * @param _slippageTolerance La tolérance de slippage.
 * @return _ Le montant de token B reçu.
 * @custom:throws InvalidToken Si le token n'est pas dans la pool.
 * @custom:throws SlippageTooHigh Si le slippage est plus élevé que le paramètre indiquant la tolérance de slippage.
 */
function swap(
    address _fromToken,
    uint256 _amountIn,
    uint256 _slippageTolerance
) external returns (uint256);
```

- Comme pour `addLiquidity`, on s'assure que le token en paramètre est `tokenA` ou `tokenB`.
- On récupère le taux de swap et le slippage avec la méthode `rate`.
- Si le slippage est plus grand que le paramètre passé par l'utilisateur, alors on revert le `swap` avec l'erreur qui va bien.
- On transfer les tokens passé par l'utilisateur vers le SM.
- On calcule la quantité de token obtenu en fonction du `swapRate`.
```
    /!\ Hint - En Solidity, 1/2 = 0, donc on multiplie tout par 1e18 et on considère les 18 premiers chiffres comme après la virgule.
    1 * 1e18 / 2 = 5 * 1e17 <=> 0.5
```



repoductible, expérience,

-> simGrid simulaiteur
-> Machine, techno fine, parametres de compilation, version de python
