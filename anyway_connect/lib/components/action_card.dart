import 'package:flutter/material.dart';

class ActionCard extends StatefulWidget {
  const ActionCard(this.title, {super.key, this.onStateChanged});

  final String title;

  final Map Function(bool state)? onStateChanged;

  @override
  State<StatefulWidget> createState() => _ActionCard();
}

class _ActionCard extends State<ActionCard> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 5))
                ]),
            padding: const EdgeInsets.all(10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: Text(widget.title,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54))),
                  Switch(
                    value: true,
                    onChanged: (bool state) => widget.onStateChanged!(state),
                    activeColor: Theme.of(context).colorScheme.secondary,
                    activeTrackColor: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.5),
                    inactiveThumbColor: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.5),
                    inactiveTrackColor: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.1),
                  )
                ],
              )
            ])));
  }
}
